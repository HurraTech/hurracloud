require 'sys/filesystem'
include Sys

class Mounter
    @queue = :mounter

    def self.perform(cmd, data = {})
        case cmd
        when 'mount_partition'    
            partition_id = data["partition_id"]
            partition = DrivePartition.find_by(id: partition_id) or return
            dev_path = partition.deviceFile
            mount_path = partition.source.mount_path
            FileUtils.mkdir_p(mount_path) unless File.directory?(mount_path)            
            Rails.logger.info "Mounting #{dev_path} #{mount_path}"
            result = `ssh hurra@172.18.0.1 '(sudo mount -t ntfs-3g #{dev_path} #{mount_path}) || (sudo mount #{dev_path} #{mount_path})'`
            Rails.logger.info "Ran `ssh hurra@172.18.0.1 '(sudo mount -t ntfs-3g #{dev_path} #{mount_path}) || (sudo mount #{dev_path} #{mount_path})'`"
            Rails.logger.info "Result #{result}"
            `touch /usr/share/hurracloud/mounts` ## triggers re-creating new mounts_monitor (see mounts_monitor.sh) 
            Resque.enqueue(Mounter, 'update_sources')
        when 'unmount_source'
            source_id = data["source_id"]
            source = Source.find_by(id: source_id) or return
            mount_path = source.mount_path
            result = `ssh hurra@172.18.0.1 'sudo umount #{mount_path}'`
            Rails.logger.info "Ran `ssh hurra@172.18.0.1 'sudo umount #{mount_path}'`"
            Rails.logger.info  "Result #{result}"
            Resque.enqueue(Mounter, 'update_sources')
        when 'mount_gdrive_account'
            gdrive_account_id = data["gdrive_account_id"]
            gdrive_account = GoogleDriveAccount.find(gdrive_account_id)
            mount_path = gdrive_account.source.mount_path
            FileUtils.mkdir_p gdrive_account.gdfuse_config_directory
            FileUtils.mkdir_p(mount_path) unless File.directory?(mount_path)    
            # Generate state and config files
            File.write("#{gdrive_account.gdfuse_config_directory}/config", gdrive_account.gdfuse_config)
            File.write("#{gdrive_account.gdfuse_config_directory}/state", gdrive_account.gdfuse_state)
            Rails.logger.info("Running command ssh hurra@172.18.0.1 'sudo /usr/local/bin/google-drive-ocamlfuse -label #{gdrive_account.source.id} -config #{gdrive_account.host_gdfuse_config_directory}/config #{gdrive_account.source.mount_path}'")
            result = `ssh hurra@172.18.0.1 'sudo /usr/local/bin/google-drive-ocamlfuse -label #{gdrive_account.source.id} -config #{gdrive_account.host_gdfuse_config_directory}/config #{mount_path}'`
            Resque.enqueue(Mounter, 'update_sources')
        when 'update_sources'
            devices = { }
            `lsblk -o NAME,SIZE,TRAN,VENDOR,MODEL -dpnlb`.split("\n").each do |line|             
                (dev, size, type, vendor, model) = line.split(" ", 5)
                devices[dev] = { model: "#{vendor.strip()} #{model.strip()}",
                                 type: type,                        
                                 capacity: (size.to_i) /1024,
                                 path: dev,
                                 partitions: [] }
                devices[dev][:uuid] = `blkid #{dev} | grep -o 'PTUUID=".[^"]*"' | cut -d '"' -f 2`.chomp()                                 
                `blkid #{dev}[1-9]*`.split("\n").each_with_index do |line|                    
                    (path, attributes) = line.split(": ",2)                    
                    next if Settings.skip_partitions.include?(path)
                    partition = { path: path}
                    re = /(([^=]*)="([^"]*)")\s+/m
                    attributes.scan(re) do |match|
                        key = match[1]
                        value = match[2]
                        partition[key] = value
                    end
                    partition["NUMBER"] = path[dev.length()..-1]

                    if !partition.key?("LABEL")
                        partition["LABEL"] = partition.key?("PARTLABEL") ? partition["PARTLABEL"] : "#{devices[dev][:model]} ##{partition["NUMBER"]}"
                    end

                    mount = Filesystem.mounts.select{ |d| d.name == path }[0]
                    Rails.logger.info "Found mount #{mount.name}" if mount
                    if mount
                        fs = Filesystem.stat(mount.mount_point)
                        partition[:size] = fs.blocks  * fs.block_size / 1024                        
                        partition[:free] = fs.blocks_available  * fs.block_size / 1024
                        partition[:used] = partition[:size] - partition[:free]
                        partition[:status] = :mounted
                    else
                        partition[:status] = :unmounted
                    end
    
                    devices[dev][:partitions] << partition
                end
            end
            attached_devs = devices.map{ |dev_id,device| device[:uuid] }
            devices.each do |dev_id, device|
    
                drive = Drive.where(unique_id: device[:uuid]).first_or_create { |s|
                    s.unique_id = device[:uuid]                
                }
                Mounter.update_drive(drive, device)
                drive.save!
                Rails.logger.info("Discovered the following device; JSON: #{JSON.pretty_generate(drive.as_json)}")
            end
            detached = Drive.where.not(unique_id: attached_devs).update_all(status: :detached)

            ### Update Google Drive Mounts statuses
            GoogleDriveAccount.all().each do |account|
                mounted = Filesystem.mounts.select{|mount| mount.mount_point == account.source.mount_path }.length > 0
                if mounted
                    account.status = :mounted 
                else
                    account.status = :unmounted
                end
                account.save!
            end
        when 'init_app'    
            app_id = data["app_id"]
            app = App.find(app_id)
            app.initCommands.each do |cmd|
                ## TODO very dangerous, change when switching to public app store
                cmd = "ssh hurra@172.18.0.1 '(sudo docker-compose -f #{app.host_app_path}/CONTENT/services.yml run --rm #{cmd})'"                
                Rails.logger.info("RUNNIND THIS CMD: #{cmd})")
                result = `#{cmd}`
                Rails.logger.info("Ran command, results: #{result}")
            end
            Resque.enqueue(Mounter, 'start_app', :app_id => app_id)    
        when 'start_app'    
            app_id = data["app_id"]
            app = App.find(app_id)
            Rails.logger.info("Starting UI for app ID #{app}")
            cmd = "ssh hurra@172.18.0.1 '(sudo docker-compose -f #{app.host_app_path}/docker-compose.runner.yml up -d)'"
            Rails.logger.info("RUNNIND THIS CMD: #{cmd})")
            result = `#{cmd}`

            Rails.logger.info("Starting services for app ID #{app}")
            cmd = "ssh hurra@172.18.0.1 '(sudo docker-compose -f #{app.host_app_path}/CONTENT/services.yml up -d)'"
            Rails.logger.info("RUNNIND THIS CMD: #{cmd})")
            result = `#{cmd}`

            app.status = :started
            app.save()
            Rails.logger.info "Ran `#{cmd}`"
            Rails.logger.info "Result #{result}"
        when 'exec_app'    
            app_id = data["app_id"]
            container = data["container"]
            cmd = data["cmd"] ### TODO: SECURITY RISK ..
            app = App.find(app_id)
            ## TODO very dangerous stuff here
            cmd = "ssh hurra@172.18.0.1 '(sudo docker-compose -f #{app.host_app_path}/CONTENT/services.yml exec -T #{container} #{cmd})'"
            Rails.logger.info("RUNNIND THIS CMD: #{cmd}")
            result = `#{cmd}`
            Rails.logger.info("Ran command, results: #{result}")
        end
        
    end

    def self.update_drive(s, device)
        Rails.logger.info("Updatign dirve information for drive #{s}")
        s.drive_type = device[:type]
        s.url = device[:path]
        s.capacity = device[:capacity]
        s.name = device[:model]
        s.status = :attached
        device[:partitions].each do |p|
            partition = DrivePartition.create_source(p[:uuid] || p["PARTUUID"] || p["LABEL"])
            partition.drive = s
            partition.name = p["LABEL"]
            partition.partitionNumber = p["NUMBER"]
            partition.deviceFile = p[:path]
            partition.status = p[:status]
            partition.filesystem = p["TYPE"]
            if p[:size]
                partition.size = p[:size]
                partition.used = p[:used]
                partition.free = p[:free]
            end
            partition.metadata = p

            Rails.logger.info("Saving partition #{partition}: #{partition.name}, whose sources is #{partition.source}")
            partition.save!
            
        end
    end    
end

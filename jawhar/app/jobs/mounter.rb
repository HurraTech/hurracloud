require 'sys/filesystem'
require 'hurra_agent_services_pb'
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
            host_mount_path = partition.source.host_mount_path
            FileUtils.mkdir_p(mount_path) unless File.directory?(mount_path)
            Rails.logger.info "Mounting (!) #{dev_path} #{host_mount_path}"
            cmd = "(mount -t ntfs-3g #{dev_path} #{host_mount_path}) || (mount #{dev_path} #{host_mount_path})"
            result = $hurraAgent.exec_command(::Proto::Command.new(command: cmd))
			Rails.logger.info("HURRAGE AGENT RESP #{result.inspect}")
            `touch /usr/share/hurracloud/mounts` ## triggers re-creating new mounts_monitor (see mounts_monitor.sh)
            Resque.enqueue(Mounter, 'update_sources')
        when 'unmount_source'
            source_id = data["source_id"]
            source = Source.find_by(id: source_id) or return
            mount_path = source.host_mount_path
            $hurraAgent.exec_command(::Proto::Command.new(command: "umount #{mount_path}"))
            Resque.enqueue(Mounter, 'update_sources')
        when 'mount_gdrive_account'
            gdrive_account_id = data["gdrive_account_id"]
            gdrive_account = GoogleDriveAccount.find(gdrive_account_id)
            mount_path = gdrive_account.source.mount_path
            host_mount_path = gdrive_account.source.host_mount_path
            FileUtils.mkdir_p gdrive_account.gdfuse_config_directory
            FileUtils.mkdir_p(mount_path) unless File.directory?(mount_path)
            # Generate state and config files
            File.write("#{gdrive_account.gdfuse_config_directory}/config", gdrive_account.gdfuse_config)
            File.write("#{gdrive_account.gdfuse_config_directory}/state", gdrive_account.gdfuse_state)
            $hurraAgent.exec_command(::Proto::Command.new(command: "/usr/local/bin/google-drive-ocamlfuse -label #{gdrive_account.source.id} -config #{gdrive_account.host_gdfuse_config_directory}/config #{host_mount_path}'"))
            Resque.enqueue(Mounter, 'update_sources')
        when 'update_sources'
            devices = { }
            `lsblk -o NAME,SIZE,TRAN,VENDOR,MODEL -dpnlb -e7`.split("\n").each do |line|
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
                cmd = "(docker-compose -p APP_#{app.app_unique_id} -f #{app.host_app_path}/CONTENT/services.yml run --rm #{cmd})'"
                $hurraAgent.exec_command(::Proto::Command.new(command: cmd))
                Rails.logger.info("RUNNIND THIS CMD: #{cmd}")
                result = `#{cmd}`
                Rails.logger.info("Ran command, results: #{result}")
            end
            Resque.enqueue(Mounter, 'start_app', :app_id => app_id)
        when 'start_app'
            app_id = data["app_id"]
            app = App.find(app_id)
            Rails.logger.info("Starting UI for app ID #{app}")
            cmd = "(docker-compose -p APP_#{app.app_unique_id} -f #{app.host_app_path}/docker-compose.runner.yml up -d)"
            Rails.logger.info("RUNNIND THIS CMD: #{cmd})")
            $hurraAgent.exec_command(::Proto::Command.new(command: cmd))
            Rails.logger.info("Starting services for app ID #{app}")
            cmd = "(docker-compose -p APP_#{app.app_unique_id} -f #{app.host_app_path}/CONTENT/services.yml up -d)"
            $hurraAgent.exec_command(::Proto::Command.new(command: cmd))
            Rails.logger.info("RUNNIND THIS CMD: #{cmd})")
            result = `#{cmd}`

            app.status = :started
            app.save()
            Rails.logger.info "Ran `#{cmd}`"
            Rails.logger.info "Result #{result}"
        when 'exec_app'
            # TODO: This whole dangerous approach on how commands are executed in other containers should be completely redone.
            cmd_id = data["cmd_id"]
            command = AppCommand.find(cmd_id)
            container = command.container
            cmd = command.command ### TODO: SECURITY RISK .. Think of secure approach to invoke commands within container
            env = ""
            env = "-e #{command.environment.map{ |k,v| "#{k}=\"#{v.to_s.gsub('"', '\"')}\"" }.join(" -e ")}" unless !command.environment || command.environment.length == 0
            app = command.app
            ## TODO very dangerous stuff here
            command.status = :executing
            command.save()
            cmd = "(docker-compose -p APP_#{app.app_unique_id} -f #{app.host_app_path}/CONTENT/services.yml exec #{env} -T #{container} bash -c \"#{cmd}\")"
            Rails.logger.info("RUNNIND THIS CMD: #{cmd}")
            $hurraAgent.exec_command(::Proto::Command.new(command: cmd))
            command.status = :completed
            command.output = result
            command.save()

            Rails.logger.info("Ran command, results: #{result}")
        when 'restart_container'
            container = data["container"]
            app_id = data["app_id"]
            app = App.find(app_id)
            Rails.logger.info("Restarting container #{container} for app ID #{app.app_unique_id}")
            cmd = "(docker-compose -p APP_#{app.app_unique_id} -f #{app.host_app_path}/CONTENT/services.yml restart #{container})"
            Rails.logger.info("RUNNIND THIS CMD: #{cmd}")
            $hurraAgent.exec_command(::Proto::Command.new(command: cmd))
            Rails.logger.info "Result #{result}"
        when 'stop_container'
            container = data["container"]
            app_id = data["app_id"]
            app = App.find(app_id)
            Rails.logger.info("Restarting container #{container} for app ID #{app.app_unique_id}")
            cmd = "(docker-compose -p APP_#{app.app_unique_id} -f #{app.host_app_path}/CONTENT/services.yml stop #{container})"
            $hurraAgent.exec_command(::Proto::Command.new(command: cmd))
            Rails.logger.info("RUNNIND THIS CMD: #{cmd}")
            result = `#{cmd}`
            Rails.logger.info "Result #{result}"
        when 'start_container'
            container = data["container"]
            app_id = data["app_id"]
            app = App.find(app_id)
            Rails.logger.info("Restarting container #{container} for app ID #{app.app_unique_id}")
            cmd = "(docker-compose -p APP_#{app.app_unique_id} -f #{app.host_app_path}/CONTENT/services.yml start #{container})"
            $hurraAgent.exec_command(::Proto::Command.new(command: cmd))
            Rails.logger.info("RUNNIND THIS CMD: #{cmd}")
            result = `#{cmd}`
            Rails.logger.info "Result #{result}"
        end
    end

    def self.update_drive(s, device)
        Rails.logger.info("Updating dirve information for drive #{s}")
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

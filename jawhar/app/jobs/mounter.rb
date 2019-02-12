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
            host_mount_path = partition.host_mount_path
            local_mount_path = partition.mount_path
            FileUtils.mkdir_p(local_mount_path) unless File.directory?(local_mount_path)            
            Rails.logger.info "Mounting #{dev_path} #{host_mount_path}"
            result = `ssh hurra@172.18.0.1 '(sudo mount -t ntfs-3g #{dev_path} #{host_mount_path}) || (sudo mount #{dev_path} #{host_mount_path})'`
            Rails.logger.info "Ran `ssh hurra@172.18.0.1 '(sudo mount -t ntfs-3g #{dev_path} #{host_mount_path}) || (sudo mount #{dev_path} #{host_mount_path})'`"
            Rails.logger.info "Result #{result}"
            `touch /usr/share/hurracloud/mounts` ## triggers re-creating new mounts_monitor (see mounts_monitor.sh) 
            Resque.enqueue(Mounter, 'update_drives')

        when 'unmount_partition'    
            partition_id = data["partition_id"]
            partition = DrivePartition.find_by(id: partition_id) or return
            dev_path = partition.deviceFile
            mount_path = partition.host_mount_path
            # FileUtils.mkdir_p(mount_path) unless File.directory?(mount_path)
            Rails.logger.info  "Unmounting #{dev_path} #{host_mount_path}"
            result = `ssh hurra@172.18.0.1 'sudo umount #{mount_path}'`
            Rails.logger.info "Ran `ssh hurra@172.18.0.1 'sudo umount #{mount_path}'`"
            Rails.logger.info  "Result #{result}"
            Resque.enqueue(Mounter, 'update_drives')
        when 'update_drives'
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
                Rails.logger.info("Discover the following JSON #{JSON.pretty_generate(drive.as_json)}")
            end
            detached = Drive.where.not(unique_id: attached_devs).update_all(status: :detached)
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

require 'sys/filesystem'
include Sys

class Mounter
    @queue = :mounter

    def self.perform(cmd, data = {})
        case cmd
        when 'mount_partition'    
            partition_id = data["partition_id"]
            partition = DevicePartition.find(partition_id) or return
            dev_path = partition.deviceFile
            mount_path = partition.mount_path
            FileUtils.mkdir_p mount_path
            puts "Mounting #{dev_path} #{mount_path}"
            result = `mount -o ro #{dev_path} #{mount_path}` 
            puts "Result #{result}"
            Resque.enqueue(Mounter, 'update_sources')

        when 'unmount_partition'    
            partition_id = data["partition_id"]
            partition = DevicePartition.find(partition_id) or return
            dev_path = partition.deviceFile
            mount_path = partition.mount_path
            FileUtils.mkdir_p mount_path
            puts "Unmounting #{dev_path} #{mount_path}"
            result = `umount #{mount_path}` 
            puts "Result #{result}"
            Resque.enqueue(Mounter, 'update_sources')
        when 'update_sources'
            devices = { }
            `lsblk -o NAME,SIZE,TRAN,VENDOR,MODEL -dpnlb`.split("\n").each do |line|             
                (dev, size, type, vendor, model) = line.split(" ", 5)
                type = :internal_storage if type == "sata"
                type = :usb if type == "usb"
                type = :system if dev == "/dev/sda"
                devices[dev] = { model: "#{vendor.strip()} #{model.strip()}",
                                 type: type,                        
                                 capacity: (size.to_i) /1024,
                                 path: dev,
                                 partitions: [] }
                devices[dev][:uuid] = `blkid #{dev} | grep -o 'PTUUID=".[^"]*"' | cut -d '"' -f 2`.chomp()                                 
                `blkid #{dev}[1-9]*`.split("\n").each_with_index do |line|
                    (path, attributes) = line.split(": ",2)                    
                    partition = { path: path}
                    re = /(([^=]*)="([^"]*)")\s+/m
                    attributes.scan(re) do |match|
                        key = match[1]
                        value = match[2]
                        partition[key] = value
                    end
                    partition["NUMBER"] = path[dev.length()..-1]

                    if !partition.key?("LABEL")
                        partition["LABEL"] = "#{devices[dev][:model]} ##{partition["NUMBER"]}"
                    end

                    mount = Filesystem.mounts.select{ |d| d.name == path }[0]
                    if mount
                        fs = Filesystem.stat(mount.mount_point)
                        partition[:size] = fs.blocks  * fs.block_size / 1024
                        partition[:available] = fs.blocks_available  * fs.block_size / 1024
                        partition[:mounted] = true            
                    else
                        partition[:mounted] = false
                    end
    
                    devices[dev][:partitions] << partition
                end
            end
            attached_devs = devices.map{ |dev_id,device| device[:uuid] }
            devices.each do |dev_id, device|
    
                s = Source.where(unique_id: device[:uuid]).first_or_create { |s|
                    s.unique_id = device[:uuid]                
                }
                Mounter.update_source(s, device)
                s.save()
                puts JSON.pretty_generate(s.as_json)
            end
            detached = Source.where.not(unique_id: attached_devs).update_all(status: :detached)
        end
    end

    def self.update_source(s, device)
        s.source_type = device[:type]
        s.url = device[:path]
        s.capacity = device[:capacity]
        s.name = device[:model]
        s.status = :attached
        device[:partitions].each do |p|
            if p[:uuid]
                partitionQuery = DevicePartition.where(source: s, uuid: p["UUID"])
            else
                partitionQuery = DevicePartition.where(source: s, label: p["LABEL"])
            end
            partition = partitionQuery.first_or_create{ |partition|
                partition.source = s
                if p["UUID"]
                    partition.uuid = p["UUID"]
                elsif p["PARTUUID"]
                    partition.uuid = p["PARTUUID"]
                end
                partition.label = p["LABEL"]
            }
            partition.partitionNumber = p["NUMBER"]
            partition.deviceFile = p[:path]
            partition.mounted = p[:mounted]
            partition.filesystem = p["TYPE"]
            if p[:size]
                partition.size = p[:size]
                partition.available = p[:available]
            end
            partition.raw = p
            partition.save()
        end
    end    
end

    
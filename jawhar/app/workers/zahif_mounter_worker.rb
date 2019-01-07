require 'fileutils'
require 'json'
require 'sys/filesystem'
include Sys

class ZahifMounterWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'mounter'

    def perform(job, data)
        case job
        when 'mount_partition'    
            source_id = data["source_id"]
            partition = data["partition"]
            puts "Mounting #{partition.inspect}"
            source = Source.find(source_id)
            dev_path = partition["path"]
            label = partition["LABEL"]
            mount_path = "#{Settings.mounts_path}#{source.id}/#{label}"
            FileUtils.mkdir_p mount_path
            puts "Mounting #{dev_path} #{mount_path}"
            result = `mount #{dev_path} #{mount_path}` 
            puts "Result #{result}"
            ZahifMounterWorker.perform_async('update_sources', {})
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
                `blkid #{dev}[1-9]*`.split("\n").each_with_index do |line, i|
                    (path, attributes) = line.split(": ",2)
                    devices[dev][:uuid] = `blkid #{dev} | grep -o 'PTUUID=".[^"]*"' | cut -d '"' -f 2`.chomp()
                    partition = { path: path}
                    re = /(([^=]*)="([^"]*)")\s+/m
                    attributes.scan(re) do |match|
                        key = match[1]
                        value = match[2]
                        partition[key] = value
                    end

                    if !partition.key?("LABEL")
                        partition["LABEL"] = "#{devices[dev][:model]} ##{i+1}"
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
                self.update_source(s, device)
                s.save()
                puts JSON.pretty_generate(s.as_json)
            end
            detached = Source.where.not(unique_id: attached_devs).update_all(status: :detached)
        end
    end

    def update_source(s, device)
        s.source_type = device[:type]
        s.url = device[:path]
        s.capacity = device[:capacity]
        s.name = device[:model]
        s.status = :attached
        s.metadata = { :partitions => device[:partitions]}
    end    
end

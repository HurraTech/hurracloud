require 'json'
require 'sys/filesystem'
include Sys
namespace :zahif_watcher do
    desc "Updates data sources"
    task :update_data_sources => :environment do


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
            `blkid #{dev}[1-9]*`.split("\n").each do |line|
                (path, attributes) = line.split(": ",2)
                devices[dev][:uuid] = `blkid #{dev} | grep -o 'PTUUID=".[^"]*"' | cut -d '"' -f 2`.chomp()
                partition = { path: path}
                re = /(([^=]*)="([^"]*)")\s+/m
                attributes.scan(re) do |match|
                    key = match[1]
                    value = match[2]
                    partition[key] = value
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
        devices.each do |dev_id, device|
            s = Source.where(unique_id: device[:uuid]).first_or_create { |s|
                s.unique_id = device[:uuid]                
            }
            update_source(s, device)
            s.save()
            puts JSON.pretty_generate(s.as_json)
            # puts s.inspect
        end
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
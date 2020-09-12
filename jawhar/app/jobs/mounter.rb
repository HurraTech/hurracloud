require 'sys/filesystem'
include Sys

class Mounter
    @queue = :mounter
    $hurraAgent = Rails.application.config.hurracloud_agent

    def self.mount_partition(data = {})
        Rails.logger.debug("In mount_partition #{data}")
        partition_id = data[:partition_id]
        partition = DrivePartition.find_by(id: partition_id) or return
        dev_path = partition.deviceFile
        mount_path = partition.source.mount_path
        host_mount_path = partition.source.host_mount_path
        result = $hurraAgent.mount_drive(::Proto::MountDriveRequest.new(device_file: dev_path, mount_point: host_mount_path))
        Mounter.update_sources
    end

    def self.unmount_source(data = {})
        source_id = data[:source_id]
        source = Source.find_by(id: source_id) or return
                mount_path = source.host_mount_path
        $hurraAgent.unmount_drive(::Proto::UnmountDriveRequest.new(device_file: source.device_file))
        Mounter.update_sources
    end

    def self.mount_gdrive_account(data = {})
        gdrive_account_id = data[:gdrive_account_id]
        gdrive_account = GoogleDriveAccount.find(gdrive_account_id)
        mount_path = gdrive_account.source.mount_path
        host_mount_path = gdrive_account.source.host_mount_path
        FileUtils.mkdir_p gdrive_account.gdfuse_config_directory
        FileUtils.mkdir_p(mount_path) unless File.directory?(mount_path)
        # Generate state and config files
        Rails.logger.info("Creating Google Fuse Config File at #{gdrive_account.gdfuse_config_directory} with contents:\n#{gdrive_account.gdfuse_config}")
        File.write("#{gdrive_account.gdfuse_config_directory}/config", gdrive_account.gdfuse_config)
        File.write("#{gdrive_account.gdfuse_config_directory}/state", gdrive_account.gdfuse_state)
        $hurraAgent.exec_command(::Proto::Command.new(command: "google-drive-ocamlfuse -label #{gdrive_account.source.id} -o allow_other -config #{gdrive_account.host_gdfuse_config_directory}/config #{host_mount_path}"))
        Mounter.update_sources
    end

    def self.update_sources(data = {})
        #### Update Internal Storage ####
        internal_mounts = Dir.glob("#{Settings.mounts_path}/internal-*").map{ |s| File.basename(s) }
        Rails.logger.info("Discovered the following internal mounts #{internal_mounts}")
        drive = Drive.where(unique_id: "internal").first_or_create { |s|
            s.unique_id = "internal"
            s.drive_type = :internal
        }
        drive.save!
        internal_mounts.each do |mount_name|
            i = mount_name.split("-")[1].to_i
            partition = DrivePartition.create_source(mount_name)
            partition.drive = drive
            partition.name = "Internal Storage #{i > 1 ? "- #{i}" : ""}".strip()
            partition.status = :mounted
            partition.filesystem = "ext4"
            partition.save!
            partition.update_stats(force: true)
        end

        ### Update Drives ####
        devices = []
        res = $hurraAgent.get_drives(::Proto::GetDrivesRequest.new())    
        Rails.logger.info("Agent this response: #{res}")         
        res.drives.each do |d|
            Rails.logger.info("Agent returned this drive: #{d}")
            drive = Drive.where(unique_id: d.serial_number).first_or_create { |s|
                s.unique_id = d.serial_number
            }
            drive.capacity = d.size_bytes
            drive.drive_type = d.type
            devices.append(drive.unique_id)
            drive.save!
            d.partitions.each do |p|
                partition = DrivePartition.create_source("#{d.serial_number}-#{p.name}")
                partition.drive = drive
                if p.label != ""
                    partition.name = p.label
                else
                    partition.name = p.name
                end
                partition.filesystem = p.filesystem
                partition.size = p.size_bytes
                if p.mount_point != ""
                    partition.status = :mounted
                else
                    partition.status = :unmounted
                end
                if p.available_bytes
                    # partition.free = p.available_bytes
                end
                partition.save!
            end
        end

        # Did any drives disappear from our last state?
        Drive.where.not(unique_id: devices, drive_type: :internal).each do |d|
          d.drive_partitions.each { |d| d.source.status = :unavailable; d.save! }
          d.status = :detached
          d.save!
        end


        #     devices[dev][:uuid] = res.message.chomp()
        #     res = $hurraAgent.exec_command(::Proto::Command.new(command: "blkid #{dev}*"))
        #     Rails.logger.info("BLKID full output is #{res.message}")
        #     output_lines = res.message.split("\n")
        #     output_lines.each_with_index do |line|
        #         Rails.logger.info("BLKID output is #{line}")
        #         next if not line.start_with?("/dev") # skip "exit status" line
        #         (path, attributes) = line.split(": ",2)
        #         next if Settings.skip_partitions.include?(path)
        #         partition = { path: path}
        #         re = /(([^=]*)="([^"]*)")\s*/m
        #         attributes.scan(re) do |match|
        #             key = match[1]
        #             value = match[2]
        #             partition[key] = value
        #         end
        #         partition["NUMBER"] = path[dev.length()..-1]

        #         if !partition.key?("LABEL")
        #             partition["LABEL"] = partition.key?("PARTLABEL") ? partition["PARTLABEL"] : "#{devices[dev][:model]} ##{partition["NUMBER"]}"
        #         end

        #         mount = Filesystem.mounts.select{ |d| d.name == path }[0]
        #         Rails.logger.info "Found mount #{mount.name}" if mount
        #         if mount
        #             fs = Filesystem.stat(mount.mount_point)
        #             partition[:size] = fs.blocks  * fs.block_size / 1024
        #             partition[:free] = fs.blocks_available  * fs.block_size / 1024
        #             partition[:used] = partition[:size] - partition[:free]
        #             partition[:status] = :mounted
        #         else
        #             partition[:status] = :unmounted
        #         end

        #         devices[dev][:partitions] << partition
        #     end
        # end
        # attached_devs = devices.map{ |dev_id,device| device[:uuid] }
        # devices.each do |dev_id, device|

        #     drive = Drive.where(unique_id: device[:uuid]).first_or_create { |s|
        #         s.unique_id = device[:uuid]
        #     }
        #     Mounter.update_drive(drive, device)
        #     drive.save!
        #     Rails.logger.info("Discovered the following device; JSON: #{JSON.pretty_generate(drive.as_json)}")
        # end
        # Rails.logger.info("Attached Devs #{attached_devs}")
        # Drive.where.not(unique_id: attached_devs, drive_type: :internal).each do |d|
        #   d.drive_partitions.each { |d| d.source.status = :unavailable; d.save! }
        #   d.status = :detached
        #   d.save!
        # end

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

    end

    def self.init_app(data = {})
        app_id = data[:app_id]
        app = App.find(app_id)
        app.initCommands.each do |cmd|
            ## TODO very dangerous, change when switching to public app store
            cmd = "(docker-compose -p APP_#{app.app_unique_id} -f #{app.host_app_path}/CONTENT/services.yml run --rm #{cmd})'"
            $hurraAgent.exec_command(::Proto::Command.new(command: cmd))
            Rails.logger.info("RUNNIND THIS CMD: #{cmd}")
            result = `#{cmd}`
            Rails.logger.info("Ran command, results: #{result}")
        end
        Mounter.start_app(:app_id => app_id)
    end

    def self.delete_app(data = {})
        app_id = data[:app_id]
        app = App.find(app_id)

        Rails.logger.info("Shutting down #{app}")
        cmd = "(docker-compose -p APP_#{app.app_unique_id} -f #{app.host_app_path}/docker-compose.runner.yml -f #{app.host_app_path}/CONTENT/services.yml down -v --remove-orphans)"
        Rails.logger.info("RUNNIND THIS CMD: #{cmd})")
        $hurraAgent.exec_command(::Proto::Command.new(command: cmd))

        Rails.logger.info("Delete app files #{app.app_path}")
        FileUtils.rm_rf(app.app_path)

        app.destroy

    end

    def self.start_app(data = {})
        app_id = data[:app_id]
        app = App.find(app_id)

        Rails.logger.info("Starting UI for app ID #{app}")
        cmd = "docker-compose -p APP_#{app.app_unique_id} -f #{app.host_app_path}/docker-compose.runner.yml -f #{app.host_app_path}/CONTENT/services.yml up -d"
        Rails.logger.info("RUNNIND THIS CMD: #{cmd})")
        $hurraAgent.exec_command(::Proto::Command.new(command: cmd))
        app.status = :started
        app.save()
    end

    def self.exec_app(data = {})
        # TODO: This whole dangerous approach on how commands are executed in other containers should be completely redone.
        cmd_id = data[:cmd_id]
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
        result = $hurraAgent.exec_command(::Proto::Command.new(command: cmd))
        command.status = :completed
        command.output = result.message
        command.save()

        Rails.logger.info("Ran command, results: #{result}")
    end

    def self.restart_container(data = {})
        container = data[:container]
        app_id = data[:app_id]
        app = App.find(app_id)
        Rails.logger.info("Restarting container #{container} for app ID #{app.app_unique_id}")
        cmd = "(docker-compose -p APP_#{app.app_unique_id} -f #{app.host_app_path}/CONTENT/services.yml restart #{container})"
        Rails.logger.info("RUNNIND THIS CMD: #{cmd}")
        $hurraAgent.exec_command(::Proto::Command.new(command: cmd))
        Rails.logger.info "Result #{result}"
    end

    def self.stop_container(data = {})
        container = data[:container]
        app_id = data[:app_id]
        app = App.find(app_id)
        Rails.logger.info("Restarting container #{container} for app ID #{app.app_unique_id}")
        cmd = "(docker-compose -p APP_#{app.app_unique_id} -f #{app.host_app_path}/CONTENT/services.yml stop #{container})"
        $hurraAgent.exec_command(::Proto::Command.new(command: cmd))
        Rails.logger.info("RUNNIND THIS CMD: #{cmd}")
        result = `#{cmd}`
        Rails.logger.info "Result #{result}"
    end

    def self.start_container(data = {})
        container = data[:container]
        app_id = data[:app_id]
        app = App.find(app_id)
        Rails.logger.info("Restarting container #{container} for app ID #{app.app_unique_id}")
        cmd = "(docker-compose -p APP_#{app.app_unique_id} -f #{app.host_app_path}/CONTENT/services.yml start #{container})"
        $hurraAgent.exec_command(::Proto::Command.new(command: cmd))
        Rails.logger.info("RUNNIND THIS CMD: #{cmd}")
        result = `#{cmd}`
        Rails.logger.info "Result #{result}"
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
            partition.metadata = p

            Rails.logger.info("Saving partition #{partition}: #{partition.name}, whose sources is #{partition.source}")
            partition.save!
            partition.update_stats(force: true)

        end
    end
end

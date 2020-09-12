class Source < ApplicationRecord
    belongs_to :sourcable, :polymorphic => true
    has_one :index
    serialize :metadata, JSON
    enum status: [ :unmounted, :mounting, :unmounting, :mounted, :unavailable ]

    def as_json(options={})
        super(options.merge!(methods: [:sourcable, :index]))
    end

    def mount_path
        if self.sourcable.respond_to?(:mount_path)
           return self.sourcable.mount_path
        end
		"#{Settings.mounts_path}/#{self.sourcable.normalized_name}"
    end

    def host_mount_path
        if self.sourcable.respond_to?(:host_mount_path)
           return self.sourcable.host_mount_path
        end
        "#{Settings.host_mounts_path}/#{self.sourcable.normalized_name}"
    end

    def device_file
        if self.sourcable.respond_to?(:device_file)
           return self.sourcable.device_file
        end
    end


    def browse(requested_path=nil)
        path = "#{self.mount_path}/#{requested_path}"
        Rails.logger.info("Browsinert #{path}")
        {
          contents: Dir.entries(path).map {|i|
            if self.sourcable.respond_to?(:file_to_json)
                self.sourcable.file_to_json(requested_path, i)
            else
                self.file_to_json(requested_path, i)
            end
          }.select{ |e| e[:name] != '.' && ( !requested_path.nil? || e[:name] != '..') }
           .sort{ |e1,e2| e1[:type] == "folder" ? -1 : 1 }
      }
    end

    def file_to_json(requested_path, file)
        path = "#{self.mount_path}/#{requested_path}"
        entry_path = "#{path}/#{file}"
        file_extension = File.extname(entry_path).downcase
        file_extension = file_extension.length > 0 ? file_extension[1..-1] : ""
        {
            name: file,
            internal_name: file,
            type: FileTest.directory?(entry_path) ? "folder": file_extension,
            path: "#{self.sourcable.normalized_name}/#{requested_path}/#{file}",
            last_modified: File.mtime(entry_path),
            filesize: File.size(entry_path)
        }
    end

    def free
      self.sourcable.update_stats
      self[:free]
    end

    def used
      self.sourcable.update_stats
      self[:used]
    end

    def unmount()
        self.status = :unmounting
        self.save()
        Mounter.unmount_source(:source_id => self.id)
    end


end

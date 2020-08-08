class Source < ApplicationRecord
    belongs_to :sourcable, :polymorphic => true
    has_one :index
    serialize :metadata, JSON
    enum status: [ :unmounted, :mounting, :unmounting, :mounted ]

    def as_json(options={})
        super(options.merge!(methods: [:sourcable, :index]))
    end

    def mount_path
        "#{Settings.mounts_path}/#{self.id}"
    end

    def host_mount_path
        "#{Settings.host_mounts_path}/#{self.id}"
    end

    def browse(requested_path=nil)
        path = "#{self.mount_path}/#{requested_path}"
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
            path: "#{self.id}/#{requested_path}/#{file}",
            last_modified: File.mtime(entry_path),
            filesize: File.size(entry_path)
        }
    end


    def unmount()
        self.status = :unmounting
        self.save()
        Resque.enqueue(Mounter, 'unmount_source', :source_id => self.id)
    end
    
    
end

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

    def browse(requested_path=nil)
        path = "#{self.mount_path}/#{requested_path}"
        { 
          contents: Dir.entries(path).map {|i|
              entry_path = "#{path}/#{i}"
              file_extension = File.extname(entry_path).downcase
              file_extension = file_extension.length > 0 ? file_extension[1..-1] : ""
              {
                  name: i,
                  internal_name: i,
                  type: FileTest.directory?(entry_path) ? "folder": file_extension,
                  path: "#{self.id}/#{requested_path}#{i}",
                  last_modified: File.mtime(entry_path),
                  filesize: File.size(entry_path)
              }
          }.select{ |e| e[:name] != '.' && ( !requested_path.nil? || e[:name] != '..') }
           .sort{ |e1,e2| e1[:type] == "folder" ? -1 : 1 }
      }
    end        

    def unmount()
        self.status = :unmounting
        self.save()
        Resque.enqueue(Mounter, 'unmount_source', :source_id => self.id)
    end
    
    
end

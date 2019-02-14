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
        "#{ENV['HOST_MOUNT_PATH']}/#{self.id}"
    end
    
    def unmount()
        self.status = :unmounting
        self.save()
        Resque.enqueue(Mounter, 'unmount_source', :source_id => self.id)
    end
    
    
end

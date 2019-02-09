class DevicePartition < ApplicationRecord
  belongs_to :source
  serialize :raw, JSON
  has_one :index
  enum status: [ :unmounted, :mounting, :unmounting, :mounted ]

  def mount()
    self.status = :mounting
    self.save()
    Resque.enqueue(Mounter, 'mount_partition', :partition_id => self.id)
  end

  def unmount()
    self.status = :unmounting
    self.save()
    Resque.enqueue(Mounter, 'unmount_partition', :partition_id => self.id)
  end

  def mount_path
    "#{Settings.mounts_path}#{self.source.id}/#{self.label}"    
  end

  def host_mount_path
    "#{ENV['HOST_MOUNT_PATH']}#{self.source.id}/#{self.label}"    
  end

  def as_json(options={})
    super(options.merge!(methods: [:index]))
  end

end

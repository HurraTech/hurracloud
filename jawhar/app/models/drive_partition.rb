class DrivePartition < ApplicationRecord
  include ActsAsSourcable
  acts_as_sourcable
  belongs_to :drive

  def mount()
    self.status = :mounting
    self.save()
    Resque.enqueue(Mounter, 'mount_partition', :partition_id => self.id)
  end

  def browse(requestedPath)
    self.source.browse(requestedPath) ## Use the common browse logic
  end

  def unmount()
    self.source.unmount() ## Use the common source unmount logic
  end

  def drive_type
    self.drive.drive_type
  end

  def as_json(options={})
    super(options.merge!(methods: [:drive_type, :is_mountable]))
  end

  def is_mountable
    self.metadata.key?("TYPE") && Settings.supported_fs_types.include?(self.metadata["TYPE"])
  end
end

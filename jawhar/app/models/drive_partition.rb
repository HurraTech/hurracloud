class DrivePartition < ApplicationRecord
  include ActsAsSourcable
  acts_as_sourcable
  belongs_to :drive

  def free
    0
  end

  def mount()
    # self.status = :mounting
    # self.save()
    Rails.logger.info("Calling Moutner.mount_partition")
    Mounter.mount_partition :partition_id => self.id
  end

  def normalized_name()
    return self.source.unique_id if self.drive_type == "internal"
    normalized_name = self.name
    bad_chars = [ '/', '\\', '?', '%', '*', ':', '|', '"', '<', '>', '.', ' ', '#', '@']
    bad_chars.each do |bad_char|
      normalized_name.gsub!(bad_char, '_')
    end
    "#{self.source.id}-#{normalized_name}"
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
    super(options.merge!(methods: [:drive_type, :is_mountable, :normalized_name]))
  end

  def is_mountable
    Settings.supported_fs_types.include?(self.filesystem)
  end
end

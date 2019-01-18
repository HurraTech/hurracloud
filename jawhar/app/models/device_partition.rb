class DevicePartition < ApplicationRecord
  belongs_to :source
  serialize :raw, JSON
  has_one :index

  def mount()
    Resque.enqueue(Mounter, 'mount_partition', :partition_id => self.id)
  end

  def unmount()
      Resque.enqueue(Mounter, 'unmount_partition', :partition_id => self.id)
  end

  def mount_path
    "#{Settings.mounts_path}#{self.source.id}/#{self.label}"    
  end

  def as_json(options={})
    super(options.merge!(methods: [:index]))
  end

end

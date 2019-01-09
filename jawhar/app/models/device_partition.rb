class DevicePartition < ApplicationRecord
  belongs_to :source
  serialize :raw, JSON

  def mount()
    ZahifMounterWorker.perform_async('mount_partition', :partition_id => self.id)
  end

  def unmount()
      ZahifMounterWorker.perform_async('unmount_partition', :partition_id => self.id)
  end

end

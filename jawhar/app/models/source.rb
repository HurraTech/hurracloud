class Source < ApplicationRecord
    enum source_type: [ :usb, :internal_storage, :system ]
    enum status: [ :attached, :detached ]
    serialize :metadata, JSON

    def mount_partition(partition_path)
        partition = self.metadata["partitions"].select{|p| p["path"] == partition_path  }[0]
        ZahifMounterWorker.perform_async('mount_partition', :source_id => self.id, :partition => partition)
    end
end

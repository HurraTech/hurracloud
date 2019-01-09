class Source < ApplicationRecord
    enum source_type: [ :usb, :internal_storage, :system ]
    enum status: [ :attached, :detached ]
    serialize :metadata, JSON
    has_many :device_partitions

    def as_json(options={})
        super(options.merge!(methods: [:device_partitions]))
    end

end

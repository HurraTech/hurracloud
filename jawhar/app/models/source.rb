class Source < ApplicationRecord
    enum source_type: [ :usb, :internal_storage, :system ]
    enum status: [ :attached, :detached ]
    serialize :metadata, JSON
end

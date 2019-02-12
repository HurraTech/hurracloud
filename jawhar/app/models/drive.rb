class Drive < ApplicationRecord
    enum status: [ :attached, :detached ]
    serialize :metadata, JSON
    has_many :drive_partitions
end

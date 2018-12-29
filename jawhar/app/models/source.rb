class Source < ApplicationRecord
    enum source_type: [ :removable_media ]
end

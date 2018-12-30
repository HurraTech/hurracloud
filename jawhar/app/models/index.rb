require 'uri'
require 'find'

class Index < ApplicationRecord
    belongs_to :source
    has_many :index_segments

    after_commit do |index|
        ZahifWorker.perform_async('initialize_index', :index_id => index.id)
    end

    def full_path
        "/usr/share/hurracloud/jawhar/sources/#{self.source.name}/"
    end

    def index_settings
        ActiveSupport::JSON.decode(self.settings)
    end
end

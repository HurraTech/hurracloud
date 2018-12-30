require 'uri'
require 'find'

class Index < ApplicationRecord
    belongs_to :source
    has_many :index_segments

    after_commit on: :create do |index|
        ZahifWorker.perform_async('initialize_index', :index_id => index.id)
    end

    def full_path
        "/usr/share/hurracloud/jawhar/sources/#{self.source.name}/"
    end

    def progress
        return 100 if self.size.to_f == 0
        ((self.indexed_count / self.size.to_f) * 100).round(2)            
    end

    def indexed_count
        (Rails.application.config.es_client.count index: "#{self.name.downcase}_*")["count"]
    end

    def index_settings
        ActiveSupport::JSON.decode(self.settings)
    end

    def as_json(options={})
        super(options.merge!(methods: [:progress, :indexed_count]))
      end
    
end

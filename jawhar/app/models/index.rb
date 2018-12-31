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
        ## TODO: Alternative algorithm factoring in slowness rate
        # now = Time.now
        # total_elapsed_minutes = self.index_segments.map{ |s| 
        #     finish_time = s.current_status == "completed" ? s.last_run : now
        #     start_time = ["init", "scheduled"].include?(s.current_status) ?  now : s.last_run_started_at
        #     puts "Segment ID: #{s.id} (status #{s.current_status} #{["init", "scheduled"].include?(s.current_status)}), start time: #{start_time}, finish time: #{finish_time}"
        #     (finish_time - start_time) / 60
        # }.inject(0,&:+)
        # self.index_segments.map{ |segment| 
        #     weight = segment.size / self.size.to_f
        #     finish_time = segment.current_status == "completed" ? segment.last_run : now
        #     start_time = ["init", "scheduled"].include?(segment.current_status) ?  now : segment.last_run_started_at
        #     minutes_since_start_run = (finish_time - start_time) / 60
        #     puts "Segment ID: #{segment.id}, weight: #{weight}, mins since last run : #{minutes_since_start_run}, total elapsed minutes: #{total_elapsed_minutes}"
        #     slowness_weight = minutes_since_start_run / total_elapsed_minutes
        #     segment.progress * ((weight + slowness_weight) / 2)
        # }.inject(0, &:+).round(2)
        self.index_segments.map{ |segment| 
            weight = (segment.size || 0) / self.size.to_f
            segment.progress * weight
        }.inject(0, &:+).round(2)
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

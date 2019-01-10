require 'uri'
require 'find'

class Index < ApplicationRecord
    belongs_to :device_partition
    has_many :index_segments
    serialize :settings, JSON

    after_commit on: :create do |index|
        ZahifIndexerWorker.perform_async('initialize_index', :index_id => index.id)
    end

    def name
        self.device_partition.label
    end

    def full_path
        self.device_partition.mount_path
    end

    def root_segment
        self.index_segments[0]
    end

    def progress
        return 100 if self.count.to_f == 0
        return 100 if self.index_segments.select{|s| s.current_status != "completed"}.length == 0
        now = Time.now
        total_elapsed_minutes = self.index_segments.map{ |s| s.relative_indexing_duration(now) }.inject(0, &:+)
        total_etas = self.index_segments.map(&:eta_minutes).inject(0, &:+)
        self.index_segments.map{ |segment| 
            count_weight = (segment.actual_count || 0) / self.count.to_f
            size_weight = (segment.actual_size || 0) / self.size.to_f
            # slowness_weight = segment.relative_indexing_duration(now) / total_elapsed_minutes
            slowness_weight = segment.eta_minutes / total_etas.to_f
            segment.progress * ((count_weight + size_weight + slowness_weight*2) / 4)
        }.inject(0, &:+).round(2)
    end

    def eta_minutes
        self.index_segments.sort_by { |s| s.eta_minutes }.reverse[0].eta_minutes
    end

    def indexed_count
        (Rails.application.config.es_client.count index: "#{self.name.downcase}_*")["count"]
    end

    def es_wildcard_name
        "#{self.name.gsub(/[\/\-_\. ]/, '_').downcase}_*"
    end

    def as_json(options={})
        super(options.merge!(methods: [:name, :progress, :indexed_count, :eta_minutes]))
    end
    
end

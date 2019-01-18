require 'uri'
require 'find'

class Index < ApplicationRecord
    belongs_to :device_partition
    has_many :index_segments
    serialize :settings, JSON
    enum status: [ :init, :initial_indexing, :indexing, :completed, :paused ]
    
    before_save do
        self.status ||= :init
    end

    after_initialize do
        if ["initial_indexing", "indexing"].include?(self.status)
            total_completed_segments = self.index_segments.select{|s| s.current_status == "completed"}.length
            total_segments = self.index_segments.length
            if total_completed_segments == total_segments
                self.status = :completed
                self.save()
            end
        end
    end

    after_commit on: :create do |index|
        Resque.enqueue(Indexer, 'initialize_index', :index_id => index.id)
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

    # def progress
    #     return 0 if self.status == "init"
    #     return 100 if self.status == "completed"
    #     now = Time.now
    #     total_elapsed_minutes = self.index_segments.map{ |s| s.relative_indexing_duration(now) }.inject(0, &:+)
    #     total_etas = self.index_segments.map(&:eta_minutes).inject(0, &:+)
    #     self.index_segments.map{ |segment| 
    #         count_weight = (segment.actual_count || 0) / self.count.to_f
    #         size_weight = (segment.actual_size || 0) / self.size.to_f
    #         # slowness_weight = segment.relative_indexing_duration(now) / total_elapsed_minutes
    #         slowness_weight = segment.eta_minutes / total_etas.to_f
    #         segment.progress * ((count_weight + size_weight + slowness_weight*2) / 4)
    #     }.inject(0, &:+).round(2)
    # end

    def progress
        return 0 if self.status == "init"
        return 100 if self.status == "completed"
        ((self.indexed_count / self.count.to_f) * 100).round(2)
    end
    
    def indexed_count
        begin
            (Rails.application.config.es_client.count index: self.es_index_name)["count"]            
        rescue => exception
            return 0            
        end
    end

    def es_index_name
        "hurracloud_#{self.name}".gsub(/[\*\/\-_\. ]/, '_').downcase        
    end

    def as_json(options={})
        super(options.merge!(methods: [:name, :progress, :indexed_count]))
    end
    
end

require 'uri'
require 'find'

class Index < ApplicationRecord
    belongs_to :device_partition
    has_many :index_segments, :dependent => :destroy
    serialize :settings, JSON
    enum status: [ :scheduled, :init, :indexing, :completed, :paused, :resuming, :pausing, :deleting, :cancelling ]

    FSCRAWLER_TEMPLATE = IO.read(File.join(Rails.root, 'app', 'fscrawler_template.json.erb'))
    FSCRAWLER_LOG4J_TEMPLATE = IO.read(File.join(Rails.root, 'app', 'fscrawler_log4j.xml.erb'))
      
    before_save do
        self.status ||= :scheduled
    end

    before_destroy do
        begin
            Rails.application.config.es_client.indices.delete index: self.es_index_name
        rescue Exception => e
            Rails.logger.error "Exception while trying to delete ES index #{self.es_index_name}: #{e}"
        end
        fscrawler_config_dir = "/usr/share/hurracloud/zahif/indices/#{self.name}"
        FileUtils.rm_rf("#{Rails.root.join('log', "zahif/#{self.name}")}")
        FileUtils.rm_rf(fscrawler_config_dir)
    end

    after_initialize do
        if ["indexing", "paused"].include?(self.status)
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
    
    def fscrawler_settings
        name = self.crawler_job_name
        index_name = self.es_index_name
        url = "#{self.full_path}"
        excludes = self.settings['excludes'] || []        
        includes = "null"
        ocr = self.settings['ocr'] || false
        ERB.new(FSCRAWLER_TEMPLATE).result(binding)
    end

    def fscrawler_settings_json
        ActiveSupport::JSON.decode(fscrawler_settings)
    end  

    def fscrawler_log4j_config
        log_file = "#{Rails.root.join('log', "zahif/scanner-#{self.es_index_name}.log")}"
        ERB.new(FSCRAWLER_LOG4J_TEMPLATE).result(binding)
    end

    def crawler_job_name
        "#{self.name}_rescan".gsub(/[\*\/\-_\. ]/, '_').downcase
    end
    
end

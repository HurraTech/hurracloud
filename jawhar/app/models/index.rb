require 'uri'
require 'find'

class Index < ApplicationRecord
    belongs_to :source
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
        # Kill scanner process (if it exists)
        pid_file = "/var/run/#{self.crawler_job_name}.pid"
        if FileTest.exists?(pid_file)
            Rails.logger.info("PID file exists for scanner process")
            pid = File.read(pid_file).to_i
            Rails.logger.info("Checking if PID #{pid} is alive")
            begin
                Process.kill("KILL", pid)
            rescue
                Rails.logger.info("Failed to kill process")
            end
        end
        fscrawler_config_dir = "/app/indices/#{self.name}"
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
      self.sanitize(self.source.name)
    end

    def sanitize(filename)
      # Bad as defined by wikipedia: https://en.wikipedia.org/wiki/Filename#Reserved_characters_and_words
      # Also have to escape the backslash
      bad_chars = [ '/', '\\', '?', '%', '*', ':', '|', '"', '<', '>', '.', ' ', '#']
      bad_chars.each do |bad_char|
        filename.gsub!(bad_char, '_')
      end
      filename
    end

    def size
        Rails.logger.info "Attempting to find documents size of index #{self.es_index_name}"
        begin
          index = Rails.application.config.es_client.indices.stats(index: self.es_index_name)
          index["indices"][self.es_index_name]["primaries"]["store"]["size_in_bytes"]
        rescue => exception
        	Rails.logger.error "Failed to find documents count of index #{self.es_index_name}: #{exception}"
            return 0
        end
    end

    def full_path
        self.source.mount_path
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
        Rails.logger.info "Attempting to find documents count of index #{self.es_index_name}"
        begin
            (Rails.application.config.es_client.count index: self.es_index_name)["count"]
        rescue => exception
        	Rails.logger.error "Failed to find documents count of index #{self.es_index_name}: #{exception}"
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
        enableOcr = self.settings['enableOr'] || false
        es_endpoint = Settings.es_endpoint
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

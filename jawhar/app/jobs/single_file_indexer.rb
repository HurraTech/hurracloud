require 'resque-retry'
require 'securerandom'
require 'open3'

class SingleFileIndexer
    extend Resque::Plugins::Retry

    @queue = :single_file_indexer

    FSCRAWLER_TEMPLATE = IO.read(File.join(Rails.root, 'app', 'fscrawler_template.json.erb'))
    FSCRAWLER_LOG4J_TEMPLATE = IO.read(File.join(Rails.root, 'app', 'fscrawler_log4j.xml.erb'))

    def self.perform(job, params)
        file = params["file"]
        job_name = SecureRandom.hex[0..8]
        parent_path = "/#{file.scan(/[^\/]*/).reject { |i| i.empty? }[0..-2].join("/")}/"
        parsed_path = file.sub("/app/mounts/", "").scan(/[^\/]*/).reject { |i| i.empty? }
        source_id = parsed_path[0]
        filename = parsed_path.last
        source = Source.where(id: source_id).first()
        if !source.index
            Rails.logger.info("Skipping #{file} as this source is not indexed")
            return
        end
        index = source.index

        Rails.logger.info "Starting index process for #{file}"
        fscrawler_root_config = "/app/indices/singles"
        fscrawler_config_dir = "#{fscrawler_root_config}/#{job_name}"
        FileUtils.mkdir_p fscrawler_config_dir
        Rails.logger.info "Created  #{fscrawler_config_dir}"
        File.write("#{fscrawler_config_dir}/_settings.json", self.fscrawler_settings(job_name, index.es_index_name, parent_path, filename, index.settings['ocr'] || false))
        File.write("#{fscrawler_config_dir}/log4j.xml", self.fscrawler_log4j_config())
        Rails.logger.info "Wrote #{fscrawler_config_dir}/_settings.json"
        cmd = "bin/fscrawler #{job_name} --loop 1 --config_dir #{fscrawler_root_config}"
        stdout, stderr, status = Open3.capture3({
                              "JAVA_HOME" => "/usr/lib/jvm/java-8-openjdk-amd64/jre/",
                              "FS_JAVA_OPTS" => "-Xmx512m -Xms512m -Dlog4j.configurationFile=#{fscrawler_config_dir}/log4j.xml"
                            }, cmd)
        Rails.logger.debug("Command #{cmd} returned: #{stdout}\n#{stderr}")
        FileUtils.rm_rf(fscrawler_config_dir)
        Rails.logger.info("Completed")
    end

    def self.fscrawler_settings(name,es_index_name, path, file, enable_ocr)
        index_name = es_index_name
        url = path
        excludes = [".*/.*"]
        includes = [file]
        ocr = enable_ocr
        ERB.new(FSCRAWLER_TEMPLATE).result(binding)
      end

      def self.fscrawler_log4j_config
        log_file = Rails.root.join('log', "zahif/singles.log")
        ERB.new(FSCRAWLER_LOG4J_TEMPLATE).result(binding)
      end

  end

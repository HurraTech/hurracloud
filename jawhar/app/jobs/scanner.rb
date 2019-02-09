require 'resque-retry'

class Scanner
    @queue = :scanners
    
    def self.perform(job)
      Rails.logger.info("Got a #{job} job.")
      begin
        case job
        when 'spawn_scanners'
            DevicePartition.where(:status => :mounted).each do |device|
                next if !device.index or device.index.status != "completed"
                Rails.logger.info("Spawning scanner for #{device.index.es_index_name} ?")        
                index = device.index        
                fscrawler_config_dir = "/usr/share/hurracloud/zahif/indices/#{index.name}"
                fscrawler_index_dir = "#{fscrawler_config_dir}/#{index.crawler_job_name}"   
                self.setup_scanner(device.index, fscrawler_config_dir, fscrawler_index_dir)
                pid_file = "/var/run/#{device.index.crawler_job_name}.pid"
                if FileTest.exists?(pid_file)
                    Rails.logger.info("PID file exists")
                    current_pid = File.read(pid_file).to_i
                    Rails.logger.info("Checking if PID #{current_pid} is alive")
                    begin
                        Process.getpgid( current_pid )     
                        Rails.logger.info("Scanner already is running. Skip")
                        next
                    rescue
                        Rails.logger.info("Process is not running, spwaning scanner")
                    end
                else
                    Rails.logger.info("Process is not running, spwaning scanner")
                end
                pid = Process.spawn({"JAVA_HOME" => "/usr/lib/jvm/java-8-openjdk-amd64/jre/",
                        "FS_JAVA_OPTS" => "-Xmx512m -Xms512m -Dlog4j.configurationFile=#{fscrawler_index_dir}/log4j.xml"},
                        'bin/fscrawler', index.crawler_job_name, '--config_dir', fscrawler_config_dir)
                File.write(pid_file, pid)
                Rails.logger.info("Spawned scanner process #{pid}")
            end

        end
      end
    end

    def self.setup_scanner(index, fscrawler_config_dir, fscrawler_index_dir)
        Rails.logger.info("Setting up scanner for #{index.es_index_name}")
        FileUtils.mkdir_p fscrawler_index_dir
        File.write("#{fscrawler_index_dir}/_settings.json", index.fscrawler_settings)
        File.write("#{fscrawler_index_dir}/log4j.xml", index.fscrawler_log4j_config)
        Rails.logger.info("Copying from '#{fscrawler_config_dir}/#{index.index_segments.first.crawler_job_name}/_status.json' to '#{fscrawler_index_dir}/")
        FileUtils.cp("#{fscrawler_config_dir}/#{index.index_segments.first.crawler_job_name}/_status.json", "#{fscrawler_index_dir}/")
        Rails.logger.info("Completed")
    end    
    
  end

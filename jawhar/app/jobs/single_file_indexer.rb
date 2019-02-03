require 'resque-retry'

class Indexer
    extend Resque::Plugins::Retry

    @queue = :indexer
    
    SEGMENT_CONTENT_THRESHOLD = 1500

    @retry_exceptions = []

    retry_criteria_check do |exception, *args|
      if exception.is_a? Resque::DirtyExit
        index_segment_id = args[1]["index_segment_id"]
        index_segment = IndexSegment.find(index_segment_id)
        Process.kill("KILL", index_segment.crawler_pid)
        index_segment.crawler_pid = nil
        index_segment.current_status = :killed
        index_segment.save()
        return false
      end  
      true
    end
  
  
  
    def self.perform(job, params)
      Rails.logger.info("Got a #{job} job. Params: #{params}")
      begin
        case job
        when 'initialize_index'
            index_id = params['index_id']
            index = Index.find(index_id)
            Rails.logger.debug "Scanning #{index.full_path}"
            i = 0
            Find.find("#{index.full_path}") do|subdirectory| 
                if FileTest.directory?(subdirectory)        
                    relative_path = "#{subdirectory.sub("#{index.full_path}", '')}/"
                    Rails.logger.debug "Counting contents of #{File.join(subdirectory, "**", "*")}"
                    count = Dir[File.join(subdirectory, "**", "*")].count
                    Rails.logger.debug "Found #{subdirectory}"
                    if count > SEGMENT_CONTENT_THRESHOLD || i == 0
                        Rails.logger.debug "Creating segment for #{subdirectory} (count=#{count})"
                        # ['', 'a-c', 'd-f', 'g-i', 'j-l', 'm-o', 'p-r', 's-u', 'v-x', 'y-z', '0-9_\.\-'].each do |char|
                        ['', 'a-d', 'e-h', 'i-l', 'm-p', 'q-t', 'u-x', 'y-z', '0-9_\.\-'].each do |char|
                            char_class = char
                            char_class = "[#{char}]" if char.size > 1
                            wildcard = ""
                            wildcard = ".*" unless char.size == 0
                            segment = IndexSegment.where(index: index, relative_path: "#{relative_path}#{char_class}#{wildcard}").first_or_create { |s| 
                                s.current_status = :init
                                s.total_count = count
                            }
                            segment.save!
                            if segment.is_root? 
                                index.count = segment.total_count
                                index.save!
                            end
                            i+=1
                        end
                    end
                else
                    next
                end
            end
            Rails.logger.info "Done creating semgents for index #{index.id}. Building relationship tree"
            #TODO: See if below can be optimized, too many loops
            # for segment in index.index_segments
            #     # Find segment's parent
            #     segment.find_parent()
            #     segment.save()
            # end
            
            for segment in index.index_segments
                # segment.update_counts()
                segment.current_status = :scheduled
                segment.save()
                Resque.enqueue(Indexer, 'index_segment',  :index_id => index.id, :index_segment_id => segment.id)
            end
            index.status = :initial_indexing
            index.save()
            Rails.logger.info "Index #{index.id} initialized and segments are scheduled"
        when 'index_segment'
            index_segment_id = params['index_segment_id']
            index_segment = IndexSegment.find(index_segment_id)
            path = "#{index_segment.index.full_path}#{index_segment.relative_path}"
            
            Rails.logger.info "Starting index process for #{path}"
            fscrawler_config_dir = "/usr/share/hurracloud/zahif/indices/#{index_segment.index.name}"
            fscrawler_index_dir = "#{fscrawler_config_dir}/segment_#{index_segment_id}"
            FileUtils.mkdir_p fscrawler_index_dir
            File.write("#{fscrawler_index_dir}/_settings.json", index_segment.fscrawler_settings)
            File.write("#{fscrawler_index_dir}/log4j.xml", index_segment.fscrawler_log4j_config)
            index_segment.current_status = index_segment.has_been_indexed? ? :indexing : :initial_indexing
            index_segment.last_run_started_at = Time.now
            index_segment.save()
            pid = Process.spawn({"JAVA_HOME" => "/usr/lib/jvm/java-8-openjdk-amd64/jre/",
                    "FS_JAVA_OPTS" => "-Xmx512m -Xms512m -Dlog4j.configurationFile=#{fscrawler_index_dir}/log4j.xml"},
                    'bin/fscrawler', "segment_#{index_segment_id}", '--loop', '1', '--config_dir', fscrawler_config_dir)

            Rails.logger.info("Spawned process #{pid}.. Waiting for it to complete")
            index_segment.crawler_pid = pid
            index_segment.save()
            Process.wait(pid)
            Rails.logger.info("Completed")
            
            index_segment.current_status = :completed
            index_segment.last_run = Time.now
            index_segment.last_duration_seconds = (index_segment.last_run - index_segment.last_run_started_at)
            index_segment.save()
        end
      end
    end
  
  end

require 'fileutils'

class ZahifWorker
  include Sidekiq::Worker

  SEGMENT_CONTENT_THRESHOLD = 5000

  
  def perform(job, params)
    puts "Got a #{job} job!!! params: #{params}"
    case job
    when 'initialize_index'
        index_id = params['index_id']
        index = Index.find(index_id)
        Find.find("#{index.full_path}") do|subdirectory| 
            if FileTest.directory?(subdirectory)        
                relative_path = "#{subdirectory.sub("#{index.full_path}", '')}/"
                count = Dir[File.join(subdirectory, "**", "*")].count
                if count > SEGMENT_CONTENT_THRESHOLD
                    puts "Creating segment for #{subdirectory} (size=#{count})"
                    segment = IndexSegment.new(index: index, relative_path: relative_path, current_status: :init, total_size: count)
                    segment.save!
                    if segment.is_root? 
                        index.size = segment.total_size
                        index.save!
                    end
                end
            else
                next
            end
        end
        puts "Done creating semgents. Building relationship tree"
        #TODO: See if below can be optimized, too many loops
        for segment in index.index_segments
            # Find segment's parent
            segment.find_parent()
            segment.save()
        end
        
        for segment in index.index_segments
            segment.update_counts()
            segment.current_status = :scheduled
            segment.save()
            ZahifWorker.perform_async('index_segment', :index_segment_id => segment.id)
        end
    when 'index_segment'
        index_segment_id = params['index_segment_id']
        index_segment = IndexSegment.find(index_segment_id)
        path = "#{index_segment.index.full_path}#{index_segment.relative_path}"
        
        puts "Starting index process for #{path}"
        fscrawler_config_dir = "/usr/share/hurracloud/zahif/indices/#{index_segment.index.name}"
        fscrawler_index_dir = "#{fscrawler_config_dir}/segment_#{index_segment_id}"
        FileUtils.mkdir_p fscrawler_index_dir
        File.write("#{fscrawler_index_dir}/_settings.json", index_segment.fscrawler_settings)
        index_segment.current_status = index_segment.has_been_indexed? ? :indexing : :initial_indexing
        index_segment.save()
        system({"JAVA_HOME" => "/usr/lib/jvm/java-8-openjdk-amd64/jre/"}, 'bin/fscrawler', "segment_#{index_segment_id}", '--debug', '--restart', '--loop', '1', '--config_dir', fscrawler_config_dir)
        index_segment.current_status = :completed
        index_segment.last_run = Time.now
        index_segment.save()
    end
  end

end

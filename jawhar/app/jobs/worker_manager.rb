class WorkerManager
    def self.perform(job, params={})
        Rails.logger.info "Got a job of type #{job}. Params #{params}"
        case job
        when 'pause'
            index = Index.find(params["index_id"]) 
            self.kill_and_dequeue_jobs(index)
            Resque.enqueue(MetadataUpdater, 'index_paused',  :index_id => index.id)
            Rails.logger.info "Pausing index #{index.id} completed"
        when 'cancel'
            index = Index.find(params["index_id"]) 
            self.kill_and_dequeue_jobs(index)
            Resque.enqueue(MetadataUpdater, 'index_cancelled',  :index_id => index.id)
            Rails.logger.info "Cancelling index #{index.id} completed"
        end
    end
  

    def self.kill_and_dequeue_jobs(index)
        pid = File.read("/var/resque.pid").to_i
        Rails.logger.info "Resque worker PID is #{pid}. Sending USR2 signal"
        # Pause processing new jobs
        Process.kill("USR2", pid)
        Rails.logger.info "USR2 signal is sent"

        # If this worker is currently processing a job for this index, let's kill it
        Resque.working.each do |w|
            if w.job["queue"] == "indexer" \
                && w.hostname == Socket.gethostname \
                && w.job["payload"]["args"][1]["index_id"] == index.id
                Rails.logger.info "Killing currently running job"
                Process.kill("USR1", pid)
            end
        end

        # Dequeue queued jobs
        Rails.logger.info "Dequeuing jobs for index #{index.id}"
        total = 0
        index.index_segments.each do |segment| 
            total = total + Resque.dequeue(Indexer, 'index_segment',  :index_id => index.id, :index_segment_id => segment.id)
        end
        Rails.logger.info "Dequeued #{total} jobs"

        # Resume processing other queued jobs 
        Rails.logger.info "Resuming processing jobs, sending signal CONT"
        Process.kill("CONT", pid)
        Rails.logger.info "CONT signal sent"

    end
  end

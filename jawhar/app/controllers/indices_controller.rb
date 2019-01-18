class IndicesController < ApiController
    skip_before_action :verify_authenticity_token

    def pause
        workers = []
        index_id = params[:index_id]
        Resque.workers.each do |w|
            queue = w.queues[0]
            if queue.starts_with?("manager-")
                workers << queue
                Resque.enqueue_to(queue, WorkerManager, "pause", :index_id => index_id)
            end
        end
        render json: { done: true, workers: workers }
    end

    def resume
        index_id = params[:index_id].to_i
        IndexSegment.where(:index_id => index_id, :current_status => [:killed, :scheduled]).each do |segment|
            Resque.enqueue(Indexer, 'index_segment',  :index_id => index_id, :index_segment_id => segment.id)
            segment.current_status = :scheduled
            segment.save()
        end
        render json: { done: true }
    end

    private
    def index_params
        params.require(:index).permit(:device_partition_id, :settings => {:excludes => []})
    end
    
end

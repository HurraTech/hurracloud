class SourcesController < ApiController

    def index
        @sources = Source.where.not(status: :detached, source_type: :system).all()
        respond_with @sources
    end

    def mount_partition
        source_id = params[:source_id]
        partition_path = "/#{params[:partition_path]}"
        source = Source.find(source_id)
        source.mount_partition(partition_path)
        render json: { done: true }
    end

end

class SourcesController < ApiController

    def index
        @sources = Source.where.not(status: :detached, source_type: :system).all()
        respond_with @sources
    end

    def mount_partition
        source_id = params[:source_id]
        partition_id = params[:partition_id]
        partition = DevicePartition.where(source_id: source_id, id: partition_id).first()
        if !partition
            render json: { error: "not found"}
            return
        end

        partition.mount()
        render json: { done: true }
    end

    def unmount_partition
        source_id = params[:source_id]
        partition_id = params[:partition_id]
        puts "SOURCE_ID #{source_id} PARITION_ID #{partition_id}"
        partition = DevicePartition.where(source_id: source_id, id: partition_id).first()
        if !partition
            render json: { error: "not found"}
            return
        end

        partition.unmount()
        render json: { done: true }
    end

end

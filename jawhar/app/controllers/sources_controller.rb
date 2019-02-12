class SourcesController < ApiController

    def index
        @sources = Source.all()
        respond_with @sources
    end

    def mount
        source = Source.find_by(id: params[:source_id]) or render json: { error: "not found"}                
        source.sourcable.mount()
        render json: { done: true }
    end

    def unmount
        source = Source.find_by(id: params[:source_id]) or render json: { error: "not found"}                
        source.sourcable.unmount()
        render json: { done: true }
    end

end

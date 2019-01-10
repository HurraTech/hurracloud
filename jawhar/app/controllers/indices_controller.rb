class IndicesController < ApiController
    skip_before_action :verify_authenticity_token

    private
    def index_params
        params.require(:index).permit(:device_partition_id, :settings => {:excludes => []})
    end
    
end

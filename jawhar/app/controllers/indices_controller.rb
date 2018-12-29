class IndicesController < ApiController
    skip_before_action :verify_authenticity_token

    def index_params
        attributes = model_attributes
        params.permit attributes << :password
    end
    
end

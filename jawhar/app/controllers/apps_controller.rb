class AppsController < ApplicationController
    def exec
        auid = params[:app_unique_id]
        render json: { app_unique_id: params[:app_unique_id], params: params[:exec] }
    end

    def install
        auid = params[:app_unique_id]
        app = App.where(app_unique_id: auid).first_or_create { |a| 
            a.app_unique_id = auid
        }
        app.install()
    end

end

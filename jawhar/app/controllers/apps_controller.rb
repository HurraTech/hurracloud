class AppsController < ApiController
    def exec
        auid = params[:app_unique_id]
        render json: { app_unique_id: params[:app_unique_id], params: params[:exec] }
    end

    def install
        auid = params[:app_auid]
        app = App.where(app_unique_id: auid).first_or_create { |a| 
            a.app_unique_id = auid
        }
        app.install()
        render json: { app: app }
    end

    def id_field
        "app_unique_id"
    end

    def id_value
        params[:auid]
    end

    private
    def app_params
        params.require(:app).permit(:state => { })
    end

end

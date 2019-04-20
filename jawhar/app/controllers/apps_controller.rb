class AppsController < ApiController

    def patch
        state = get_resource.state.deep_merge(app_params[:state].to_h)
        if get_resource.update({ :state => state })
            render json: get_resource, status: 200
        else
          render json: get_resource.errors, status: :unprocessable_entity
        end
    end

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

    def exec
        auid = params[:app_auid]
        container = params[:container]
        cmd = params[:cmd]
        env = params[:env]
        cmd = App.find_by(app_unique_id: auid).exec(container, cmd, env || [])
        render json: { command: cmd } 
    end

    def restart_container
        auid = params[:app_auid]
        container = params[:container]
        cmd = App.find_by(app_unique_id: auid).restart_container(container)
        render json: { status: :scheduled } 
    end

    def stop_container
        auid = params[:app_auid]
        container = params[:container]
        cmd = App.find_by(app_unique_id: auid).stop_container(container)
        render json: { status: :scheduled } 
    end

    def start_container
        auid = params[:app_auid]
        container = params[:container]
        cmd = App.find_by(app_unique_id: auid).start_container(container)
        render json: { status: :scheduled } 
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

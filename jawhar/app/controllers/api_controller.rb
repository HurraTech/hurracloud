class ApiController < ApplicationController
    respond_to :json, :html

    prepend_before_action :inject_resource, only: [:destroy, :show, :update]
    def get_resource
        instance_variable_get("@#{resource_name}")
    end

    def index
        plural_name = resource_name.pluralize
        result = resource_class.all()
        instance_variable_set("@#{plural_name}", result)
        respond_with instance_variable_get("@#{plural_name}")
    end

    def create
        puts "resource params are #{resource_params}"
        inject_resource(resource_class.new(resource_params))
        if get_resource.save
          render json: get_resource, status: :created
        else
          render json: get_resource.errors, status: :unprocessable_entity
        end
    end

    def update
        if get_resource.update(resource_params)
            render json: get_resource, status: 200
        else
          render json: get_resource.errors, status: :unprocessable_entity
        end
    end

    def show
        respond_with get_resource
    end

    private 
    def inject_resource(resource=nil)
        resource ||= resource_class.where("#{id_field} = ?", id_value).first() or render json: { error: "not found"}                
        instance_variable_set("@#{resource_name}", resource)
    end

    def id_field
        "id"
    end

    def id_value
        params[:id]
    end

    def resource_name
        @resource_name ||= self.controller_name.singularize
    end

    def resource_class
        @resource_class ||= resource_name.classify.constantize
    end

    def model_attributes
        @resource_class.attribute_names.map{|s| s.to_sym} - [:created_at, :updated_at]
    end
    
    def resource_params
        @resource_params ||= self.send("#{resource_name}_params")
    end

end

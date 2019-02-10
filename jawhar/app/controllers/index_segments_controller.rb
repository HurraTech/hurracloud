class IndexSegmentsController < ApiController

    def index
        plural_name = resource_name.pluralize
        result = resource_class.where(index_id: params[:index_id])
        instance_variable_set("@#{plural_name}", result)
        # @index_segments = @index_segments.sort_by { |s| s.indexing_duration_minutes }.reverse
        respond_with @index_segments
    end

end

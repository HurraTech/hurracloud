require 'ruby-filemagic'
class FilesController < ApplicationController
    after_action :allow_iframe_cors

    def proxy
        file = "#{Settings.mounts_path}/#{params[:path]}"
        
        disposition = :attachment # file will be downloaded by browser
        if ! ["view", "download", "is_viewable"].include?(params[:file_action])
            render :json => { :error => "Invalid action #{params[:file_action]}. Valid actions: 'view', 'download'" }, :status => 400
            return
        elsif params[:file_action] == 'view' || params[:file_action] == 'is_viewable'
            mime = FileMagic.new(FileMagic::MAGIC_MIME).file(file, true)
            disposition = :inline if Settings.inline_files.allowed_mimes.include?(mime)
        elsif params[:file_action] == 'download'
            file_extension = File.extname(file)[1..-1]
            mime = Mime::Type.lookup_by_extension(file_extension).to_s
            mime = "application/octet-stream" if mime == ""
        end

        if params[:file_action] == 'is_viewable'
            render json: { is_viewable: Settings.inline_files.allowed_mimes.include?(mime) }
            return
        end
        send_file(file,
            :filename => File.basename(file),
            :type => mime,
            :disposition => disposition)
    end

    def browse
        source_id = params[:source_id]        
        source = Source.find(source_id) or render json: { error: "not found"}
        render json: source.sourcable.browse(params[:path])
    end

    private
    def allow_iframe_cors
        response.headers['Access-Control-Allow-Origin'] = Settings.samaa_root_url
        response.headers['Access-Control-Allow-Methods'] = 'GET'
        response.headers.except! 'X-Frame-Options'
    end    

end

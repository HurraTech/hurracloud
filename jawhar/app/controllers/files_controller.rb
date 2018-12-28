require 'ruby-filemagic'


class FilesController < ApplicationController
    after_action :allow_iframe_cors, only: :proxy

    def proxy
        file = "/usr/share/hurracloud/jawhar/sources/HurraDrive/#{params[:path]}"
        
        disposition = :attachment # file will be downloaded by browser
        if ! ["view", "download", "is_viewable"].include?(params[:file_action])
            render :json => { :error => "Invalid action #{params[:file_action]}. Valid actions: 'view', 'download'" }, :status => 400
            return
        elsif params[:file_action] == 'view' || params[:file_action] == 'is_viewable'
            mime = FileMagic.new(FileMagic::MAGIC_MIME).file(file, true)
            disposition = :inline if Settings.inline_files.allowed_mimes.include?(mime)
        elsif params[:file_action] == 'download'
            file_extension = File.extname(params[:path])[1..-1]
            mime = Mime::Type.lookup_by_extension(file_extension).to_s
        end

        if params[:file_action] == 'is_viewable'
            render json: { is_viewable: Settings.inline_files.allowed_mimes.include?(mime) }
            return
        end
        send_file(file,
            :filename => File.basename(params[:path]),
            :type => mime,
            :disposition => disposition)
    end

    private
    def allow_iframe_cors
        response.headers['Access-Control-Allow-Origin'] = 'http://192.168.1.2:3000'
        response.headers['Access-Control-Allow-Methods'] = 'GET'
        response.headers.except! 'X-Frame-Options'
      end    

end

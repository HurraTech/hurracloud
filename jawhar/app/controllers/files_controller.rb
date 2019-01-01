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
        if params[:source_name].nil?
            render json: {
                contents: Source.all().map{ |source|
                    {
                        name: source.name,
                        type: "source_drive",
                        last_modified: "",
                        filesize: ""
                    }
                }
            } 
            return
        end
        source_name = params[:source_name]
        source = Source.where(name: source_name).first() or render json: { error: "not found"}
        path = "#{Settings.mounts_path}/#{source.name}/#{params[:path]}"
        path_is_root = params[:path].nil?
        return if source.nil?
        render json: { 
            contents: Dir.entries(path).map {|i|
                entry_path = "#{path}/#{i}"
                file_extension = File.extname(entry_path).downcase
                file_extension = file_extension.length > 0 ? file_extension[1..-1] : ""
                {
                    name: i,
                    type: FileTest.directory?(entry_path) ? "folder": file_extension,
                    last_modified: File.mtime(entry_path),
                    filesize: File.size(entry_path)
                }
            }.select{ |e| e[:name] != '.' }
             .sort{ |e1,e2| e1[:type] == "folder" ? -1 : 1 }
        }
    end

    private
    def allow_iframe_cors
        response.headers['Access-Control-Allow-Origin'] = 'http://192.168.1.2:3000'
        response.headers['Access-Control-Allow-Methods'] = 'GET'
        response.headers.except! 'X-Frame-Options'
      end    

end

require "googleauth"
require 'google/apis/drive_v3'

class GoogleDriveAccount < ApplicationRecord
    include ActsAsSourcable  
    acts_as_sourcable

    GDFUSE_STATE_TEMPLATE  = IO.read(File.join(Rails.root, 'app', 'gdfuse_state_template.erb'))
    GDFUSE_CONFIG_TEMPLATE = IO.read(File.join(Rails.root, 'app', 'gdfuse_config_template.erb'))


    def update_usage
        quota = client.get_about(fields: 'storageQuota').storage_quota
        self.source.size = quota.limit.to_i
        self.source.used = quota.usage.to_i
        self.source.free = self.source.size - self.source.used
    end

    # def browse(requested_path)
    #     parent = "root"
    #     parent = requested_path if !requested_path.nil?
    #     response = {contents:
    #         client.list_files(fields: 'files(name,size,modifiedTime,mimeType,id,webContentLink)', order_by: 'folder', q: "'#{parent}' in parents").files.map{|file| self.normalize_file_entry(file) }
    #     }
    #     response[:contents].unshift({ name: "..", internal_name: "..", type: "folder" }) if !requested_path.nil?
    #     response        
    # end

    def browse(requested_path=nil)
        path = "#{self.source.mount_path}/#{requested_path}"
        { 
          contents: Dir.entries(path).map {|i|
              entry_path = "#{path}/#{i}"
              file_extension = File.extname(entry_path).downcase
              file_extension = file_extension.length > 0 ? file_extension[1..-1] : ""
              {
                  name: i,
                  internal_name: i,
                  type: FileTest.directory?(entry_path) ? "folder": file_extension,
                  path: "#{self.source.id}/#{requested_path}#{i}",
                  last_modified: File.mtime(entry_path),
                  filesize: File.size(entry_path)
              }
          }.select{ |e| e[:name] != '.' && ( !requested_path.nil? || e[:name] != '..') }
           .sort{ |e1,e2| e1[:type] == "folder" ? -1 : 1 }
      }
      end
    

    def client
        @client ||= Google::Apis::DriveV3::DriveService.new
        @client.authorization = credentials
        @client
    end

    def mount
        self.status = :mounting
        self.save()
        Resque.enqueue(Mounter, 'mount_gdrive_account', :gdrive_account_id => self.id)    
    end

    def unmount()
        self.source.unmount() ## Use the common source unmount logic
    end

    def unmount
        self.accessToken = nil
        self.refreshToken = nil
        self.source.status = :unmounted
        self.save!
    end

    def credentials
        credentials = Signet::OAuth2::Client.new(
            :client_id => '647498924470-rvr9l3drsfmnc3k7cnghrvn8jd2k42l8.apps.googleusercontent.com',
            :client_secret => '2QCIvHTt1eNIWsjC5e2jrT_D',
            :authorization_uri => 'https://accounts.google.com/o/oauth2/auth',
            :token_credential_uri =>  'https://oauth2.googleapis.com/token',
            :redirect_uri => "urn:ietf:wg:oauth:2.0:oob",
            :scope => "email https://www.googleapis.com/auth/drive"
        )
        credentials.refresh_token = self.refreshToken
        credentials
    end

    def gdfuse_state
        access_token = self.accessToken
        refresh_token = self.refreshToken
        auth_request_date = self.created_at.rfc3339
        access_token_date = self.issuedAt.rfc3339
        ERB.new(GDFUSE_STATE_TEMPLATE).result(binding)
    end

    def gdfuse_config
        gdfuse_host_directory = self.host_gdfuse_config_directory()
        ERB.new(GDFUSE_CONFIG_TEMPLATE).result(binding)
    end

    def gdfuse_config_directory
        "#{Settings.gdfuse_path}/#{self.id}"
    end

    def host_gdfuse_config_directory
        "#{ENV['HOST_GDFUSE_PATH']}/#{self.id}"
    end

    def normalize_file_entry(entry)
        file_extension = File.extname(entry.name).downcase
        file_extension = file_extension.length > 0 ? file_extension[1..-1] : ""
        file_type =  GoogleDriveAccount.determine_file_type(entry.name, entry.mime_type)
        {
            name: entry.name,
            internal_name: entry.id,
            type: file_type,
            path: "#{self.source.id}/#{entry.id}",
            last_modified: entry.modified_time,
            filesize: entry.size.nil? ? 0 : entry.size,
            web_link: entry.web_content_link,
            open_link: GoogleDriveAccount.is_file_google_doc?(entry.mime_type) ? "https://drive.google.com/open?id=#{entry.id}" : nil,
            mime_type: entry.mime_type
        }
    end

    def self.determine_file_type(file_name, google_mime_type)
        file_extension = File.extname(file_name).downcase
        file_extension = file_extension.length > 0 ? file_extension[1..-1] : ""
        case google_mime_type
        when 'application/vnd.google-apps.folder'
            'folder'
        when 'application/vnd.google-apps.document'
            'gdoc'
        when 'application/vnd.google-apps.spreadsheet'
            'gsheet'
        when 'application/vnd.google-apps.presentation'
            'gslide'
        when 'application/vnd.google-apps.site'
            'gsite'
        when 'application/vnd.google-apps.form'
            'gform'
        when 'application/vnd.google-apps.video'
            'mov'
        when 'application/vnd.google-apps.script'
            'tcsh'
        else
            file_extension
        end
    end

    def self.is_file_google_doc?(mime_type)
        mime_type.starts_with?("application/vnd.google-apps") && mime_type != "application/vnd.google-apps.folder"
    end

    # "name": "EFI",
    # "type": "folder",
    # "path": "4/EFI",
    # "last_modified": "2018-10-24T19:04:44.000+00:00",
    # "filesize": 2048

end

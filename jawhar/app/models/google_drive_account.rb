require "googleauth"
require 'google/apis/drive_v3'

class GoogleDriveAccount < ApplicationRecord
    include ActsAsSourcable  
    acts_as_sourcable

    def browse(requested_path)
        parent = "root"
        parent = requested_path if !requested_path.nil?
        response = {contents:
            client.list_files(fields: 'files(name,size,modifiedTime,mimeType,id)', order_by: 'folder', q: "'#{parent}' in parents").files.map{|file| self.normalize_file_entry(file) }
        }
        response[:contents].unshift({ name: "..", internalName: "..", type: "folder" }) if !requested_path.nil?
        response
    end

    def client
        @client ||= Google::Apis::DriveV3::DriveService.new
        @client.authorization = credentials
        @client
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

    def normalize_file_entry(entry)
        file_extension = File.extname(entry.name).downcase
        file_extension = file_extension.length > 0 ? file_extension[1..-1] : ""
        {
            name: entry.name,
            internalName: entry.id,
            type: GoogleDriveAccount.determine_file_type(entry.name, entry.mime_type),
            path: "#{self.source.id}/#{entry.id}",
            last_modified: entry.modified_time,
            filesize: entry.size.nil? ? 0 : entry.size
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

    # "name": "EFI",
    # "type": "folder",
    # "path": "4/EFI",
    # "last_modified": "2018-10-24T19:04:44.000+00:00",
    # "filesize": 2048

end

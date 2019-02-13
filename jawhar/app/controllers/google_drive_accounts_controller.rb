require 'signet/oauth_2/client'
require 'jwt'

class GoogleDriveAccountsController < ApiController

    def create
        client = Signet::OAuth2::Client.new(
            :client_id => '647498924470-rvr9l3drsfmnc3k7cnghrvn8jd2k42l8.apps.googleusercontent.com',
            :client_secret => '2QCIvHTt1eNIWsjC5e2jrT_D',
            :authorization_uri => 'https://accounts.google.com/o/oauth2/auth',
            :token_credential_uri =>  'https://oauth2.googleapis.com/token',
            :redirect_uri => "urn:ietf:wg:oauth:2.0:oob",
            :scope => "email https://www.googleapis.com/auth/drive.readonly",
            :additional_parameters => { "access_type" => "offline" }
        )
        client.code = params["authCode"]
        token = client.fetch_access_token!
        id_token = JWT.decode token["id_token"], nil, false
        account = GoogleDriveAccount.create_source(id_token[0]["email"])
        account.name = id_token[0]["email"]
        account.email = id_token[0]["email"]
        account.accessToken = token["access_token"]
        account.refreshToken = token["refresh_token"]
        account.issuedAt = Time.at(id_token[0]["iat"])
        account.expiresAt = Time.at(id_token[0]["exp"])
        account.status = :mounted
        account.update_usage()
        account.save()
        
        render json: {account: account, token: token, idToken: id_token}
    end

    private
    def google_drive_account_params
        params.require(:google_drive_account).permit(:authCode)
    end

end

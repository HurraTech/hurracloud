class CreateGoogleDriveAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :google_drive_accounts do |t|
      t.string :accessToken
      t.string :authCode
      t.string :refreshToken
      t.string :email
      t.string :idToken
      t.timestamp :issuedAt
      t.timestamp :expiresAt
      t.timestamps
    end
  end
end
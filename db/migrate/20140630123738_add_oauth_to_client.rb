class AddOauthToClient < ActiveRecord::Migration
  def change
  	   add_column :clients, :provider, :string
       add_column :clients, :uid, :string
       add_column :clients, :oauth_token, :string
       add_column :clients, :oauth_expires_at, :datetime
      
  end
end

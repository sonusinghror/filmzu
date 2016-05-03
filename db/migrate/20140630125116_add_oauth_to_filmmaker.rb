class AddOauthToFilmmaker < ActiveRecord::Migration
  def change
       add_column :filmmakers, :oauth_token, :string
       add_column :filmmakers, :oauth_expires_at, :datetime
  end
end

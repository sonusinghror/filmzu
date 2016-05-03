class AddTokenToClient < ActiveRecord::Migration
  def change
     add_column :clients, :fb_token, :string
     add_column :clients, :linkedin_token, :string
  end
end

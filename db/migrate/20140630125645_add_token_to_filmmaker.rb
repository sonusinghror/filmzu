class AddTokenToFilmmaker < ActiveRecord::Migration
  def change
  add_column :filmmakers, :fb_token, :string
  add_column :filmmakers, :linkedin_token, :string
  end
end

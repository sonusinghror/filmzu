class AddPortfolioToFilmmakers < ActiveRecord::Migration
  def change
  add_column :filmmakers, :about, :text
  add_column :filmmakers, :location, :string
  add_column :filmmakers, :latitude, :float 
  add_column :filmmakers, :longitude, :float
  add_column :filmmakers, :skills, :text   
  end
end

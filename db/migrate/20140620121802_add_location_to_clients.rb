class AddLocationToClients < ActiveRecord::Migration
  def change
  add_column :clients, :location, :string
  add_column :clients, :latitude, :float 
  add_column :clients, :longitude, :float
  end
end

class AddFieldsToClients < ActiveRecord::Migration
  def change
    add_column :clients, :verified, :boolean
    add_column :clients, :verified_by_admin, :boolean
  end
end

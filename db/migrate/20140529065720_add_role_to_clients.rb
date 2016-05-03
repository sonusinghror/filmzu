class AddRoleToClients < ActiveRecord::Migration
  def change
    add_column :clients, :role, :string
  end
end

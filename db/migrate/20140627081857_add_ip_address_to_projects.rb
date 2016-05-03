class AddIpAddressToProjects < ActiveRecord::Migration
  def change
		add_column :projects, :ip_address, :string
  end
end

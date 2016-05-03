class AddPriceToProjects < ActiveRecord::Migration
  def self.up
		add_column :projects, :price, :float
  end

	def self.down
		remove_column :projects, :price
	end
end

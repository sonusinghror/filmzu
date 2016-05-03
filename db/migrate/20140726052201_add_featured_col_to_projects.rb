class AddFeaturedColToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :is_featured, :boolean, :default => false
  end
  
end

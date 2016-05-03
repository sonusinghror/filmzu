class AddProjectIdToProjectProposals < ActiveRecord::Migration
  def change
		add_column :project_proposals, :project_id, :integer
		add_column :project_proposals, :filmmaker_id, :integer
		remove_column :project_proposals, :proposable_id
		remove_column :project_proposals, :proposable_type
  end
end

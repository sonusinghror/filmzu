class AddProjectIdToDirectHireProposals < ActiveRecord::Migration
  def change
    add_column :direct_hire_proposals, :project_id, :integer, after: 'conversation_id'
  end
end

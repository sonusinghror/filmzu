class AddProposalRevisionIdToUpdatedProjectProposals < ActiveRecord::Migration
  def change
    add_column :updated_project_proposal_milestones, :proposal_revision_id, :integer, :after => :project_proposal_id
  end
end

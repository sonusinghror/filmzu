class AddProposalRevisionToProjectHire < ActiveRecord::Migration
  def change
    add_column :project_hires, :proposal_revision_id, :integer
  end
end

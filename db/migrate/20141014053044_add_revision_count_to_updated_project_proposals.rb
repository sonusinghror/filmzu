class AddRevisionCountToUpdatedProjectProposals < ActiveRecord::Migration
  def change
    add_column :updated_project_proposal_milestones, :revision_count, :integer, :after => :pay_amount
  end
end

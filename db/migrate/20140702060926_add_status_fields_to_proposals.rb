class AddStatusFieldsToProposals < ActiveRecord::Migration
  def self.up
    add_column :project_proposals,           :is_declined,      :boolean, :default => false
    add_column :project_proposals,           :is_approved,      :boolean, :default => false
    add_column :project_proposals,           :approved_by,      :integer
    add_column :project_proposal_milestones, :is_complete,      :boolean, :default => false
    add_column :project_proposal_milestones, :payment_released, :boolean, :default => false
  end
  
  def self.down
    remove_column :project_proposals,           :is_declined
    remove_column :project_proposals,           :is_approved
    remove_column :project_proposals,           :approved_by
    remove_column :project_proposal_milestones, :is_complete
    remove_column :project_proposal_milestones, :payment_released
  end
end
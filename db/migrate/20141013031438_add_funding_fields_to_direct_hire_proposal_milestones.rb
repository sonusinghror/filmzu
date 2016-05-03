class AddFundingFieldsToDirectHireProposalMilestones < ActiveRecord::Migration
  def change
    add_column :direct_hire_proposal_milestones, :is_complete, :boolean, default: false
    add_column :direct_hire_proposal_milestones, :payment_released, :boolean, default: false
    add_column :direct_hire_proposal_milestones, :fund_escrowed, :boolean, default: false
    add_column :direct_hire_proposal_milestones, :escrowed_at, :datetime
    add_column :direct_hire_proposal_milestones, :pay_amount, :float, default: 0.0
  end
end

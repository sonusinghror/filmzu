class AddFundStatusColsToMilestones < ActiveRecord::Migration
  def change
    add_column :project_proposal_milestones, :fund_escrowed, :boolean, :default => false
    add_column :project_proposal_milestones, :escrowed_at,   :datetime
    add_column :project_proposal_milestones, :pay_amount,    :float,   :default => 0
  end
end

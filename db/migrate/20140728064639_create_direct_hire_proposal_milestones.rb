class CreateDirectHireProposalMilestones < ActiveRecord::Migration
  def change
    create_table :direct_hire_proposal_milestones do |t|
      t.string :name
      t.date :delivery_date
      t.float :amount
      t.references :direct_hire_proposal
      t.timestamps
    end
  end
end

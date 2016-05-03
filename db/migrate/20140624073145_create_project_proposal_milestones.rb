class CreateProjectProposalMilestones < ActiveRecord::Migration
  def change
    create_table :project_proposal_milestones do |t|
      t.string :name
      t.date :delivery_date
      t.float :amount
			t.references :project_proposal
      t.timestamps
    end
  end
end

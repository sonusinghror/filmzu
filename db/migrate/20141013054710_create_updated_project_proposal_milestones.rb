class CreateUpdatedProjectProposalMilestones < ActiveRecord::Migration
  def change
    create_table :updated_project_proposal_milestones do |t|
      t.references :project_proposal
      t.string :name
      t.date :delivery_date
      t.float :amount
			t.boolean :fund_escrowed, default: false
			t.boolean :payment_released, default: false
			t.boolean :is_complete, default: false
			t.float :pay_amount, default: 0
			t.datetime :escrowed_at
      t.timestamps
    end
  end
end

class UpdatedProjectProposalMilestone < ActiveRecord::Base
attr_accessible :amount, :delivery_date, :name, :is_complete, :revision_count, :payment_released, :fund_escrowed, :escrowed_at, :pay_amount
	belongs_to :project_proposal  
	belongs_to :proposal_revision
end

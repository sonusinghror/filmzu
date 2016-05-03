class ProjectProposalMilestone < ActiveRecord::Base
  attr_accessible :amount, :delivery_date, :name, :is_complete, :payment_released, :fund_escrowed, :escrowed_at, :pay_amount
	belongs_to :project_proposal
end

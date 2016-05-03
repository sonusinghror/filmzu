class DirectHireProposal < ActiveRecord::Base
  attr_accessible :cover_letter, :desired_end_date, :desired_start_date, :is_approved,
                  :is_declined, :client_id, :filmmaker_id, :conversation_id, :project_id
  has_many :direct_hire_proposal_milestones
  belongs_to :filmmaker
  belongs_to :client
  belongs_to :conversation
  belongs_to :project
  has_many :project_direct_hires

  scope :approved, -> { where(is_approved: true) }

  def create_direct_hire_proposal_milestones milestones_data
    milestones_data.each do |milestone|
			temp_date = milestone[:date].split('/')
			milestone[:date] = [temp_date[2], temp_date[0], temp_date[1]].join("-")
			unless (milestone[:title].blank? || milestone[:date].blank? || milestone[:amount].blank?)
			  attributes = {:name => milestone[:title],
                                        :delivery_date => milestone[:date],
                                        :amount => milestone[:amount]}
			  self.direct_hire_proposal_milestones.create(attributes)
			end
		end
  end
end

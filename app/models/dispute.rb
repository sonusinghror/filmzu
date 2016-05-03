class Dispute < ActiveRecord::Base
  attr_accessible :dispute_date, :dispute_description, :proposal_id, :status
  belongs_to :project_proposal, :foreign_key => :proposal_id
  has_many :dispute_attachments
end
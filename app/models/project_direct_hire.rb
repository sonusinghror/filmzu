class ProjectDirectHire < ActiveRecord::Base
  attr_accessible :filmmaker_id, :client_id, :direct_hire_proposal_id
  belongs_to :client
  belongs_to :filmmaker
  belongs_to :direct_hire_proposal

  def self.hire_filmmaker direct_hire_proposal
    new_hire = ProjectDirectHire.new(
                filmmaker_id: direct_hire_proposal.filmmaker_id,
                client_id: direct_hire_proposal.project.user_id,
                proposal_id: direct_hire_proposal.id
              )
    new_hire.save
  end
end

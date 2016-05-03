class DirectHire < ActiveRecord::Base
 attr_accessible :filmmaker_id, :client_id, :direct_hire_proposal_id
 belongs_to :filmmaker
 belongs_to :client
 belongs_to :direct_hire_proposal
 
 def self.hire_filmmaker direct_hire_proposal
  new_hire = DirectHire.new(:filmmaker_id            => direct_hire_proposal.filmmaker_id,
                            :client_id               => direct_hire_proposal.client_id,
                            :direct_hire_proposal_id => direct_hire_proposal.id
                            )
  new_hire.save
 end
 
 def self.all_direct_hire_projects
   DirectHire.all.collect(&:direct_hire_proposal).uniq.collect(&:project).reject(&:blank?).uniq.collect(&:id)
 end

end

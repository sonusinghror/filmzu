class ProjectHire < ActiveRecord::Base
  attr_accessible :filmmaker_id, :proposal_id, :client_id, :proposal_revision_id
  belongs_to :client
  belongs_to :filmmaker
  belongs_to :proposal_revision
  belongs_to :project_proposal, :class_name => "ProjectProposal", :foreign_key => :proposal_id

  def self.hire_filmmaker project_proposal, from=nil
    new_hire = ProjectHire.new(:filmmaker_id => project_proposal.filmmaker_id,
                               :client_id => project_proposal.project.user_id,
                               :proposal_id => project_proposal.id
                              )
    if new_hire.save
      filmmaker = Filmmaker.where(id: project_proposal.filmmaker_id).first
      client = Client.where(id: project_proposal.project.user_id).first
      if filmmaker.present? && client.present? && !from.blank?
        if (from == "client")
          client.send_message(filmmaker, "Your proposal has been accepted for #{project_proposal.project.title rescue nil}", 'Your proposal has been accepted')
        else
          filmmaker.send_message(client, "Your proposal has been accepted for #{project_proposal.project.title rescue nil}", 'Your proposal has been accepted')
        end
      end
    end
  end

end

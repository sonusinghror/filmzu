class ProposalRevision < ActiveRecord::Base
  attr_accessible :description, :revised_user_type, :revised_by, :revision_count
  belongs_to :project_proposal
  has_many :updated_project_proposal_milestones, :dependent => :destroy
  has_many :project_hires

  def create_modified_proposal_milestones	milestones_data
  	milestones_data.each do |milestone|
			temp_date = milestone[:date].split('/')
			milestone[:date] = [temp_date[2], temp_date[0], temp_date[1]].join("-")
			unless (milestone[:title].blank? || milestone[:date].blank? || milestone[:amount].blank?)
		    attributes = {:name => milestone[:title],
									    :delivery_date => milestone[:date],
									    :amount => milestone[:amount] }
		    self.updated_project_proposal_milestones.create(attributes)
		  end
	  end
	  proposal = self.project_proposal
	  if proposal.present? &&  !proposal.proposal_revisions.blank? && self.updated_project_proposal_milestones.present?
	    proposal.update_attribute(:is_modified, true)
	    begin
        project = proposal.project
        client = project.client if project.present?
        filmmaker = proposal.filmmaker
        message = 'Your proposal has been changed'
        if project.present? && client.present? && filmmaker.present?
          content = ApplicationController.new.render_to_string( layout: false, partial: "filmmakers/updated_proposal_content", locals: { project_proposal: proposal })
          if self.revised_user_type == "filmmaker"
            filmmaker.send_message(client, content, message)
          else
            client.send_message(filmmaker, content, message)
          end
        end
     rescue Exception => e
        Rails.logger.debug "\n Exception: #{e.inspect}\n"
     end
	  end
  end

  def revised_user
    if revised_user_type == "filmmaker"
      Filmmaker.find(revised_by)
    else
      Client.find(revised_by)
    end
  end

end

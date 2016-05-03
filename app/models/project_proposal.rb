class ProjectProposal < ActiveRecord::Base
  attr_accessible :cover_letter, :desired_end_date, :desired_start_date, :is_modified, :is_declined, :is_approved, :approved_by, :project_id, :is_delete
	belongs_to :project
	belongs_to :filmmaker, :class_name => 'Filmmaker', :foreign_key => :filmmaker_id
	has_many :project_proposal_milestones, :dependent => :destroy
	has_many :updated_project_proposal_milestones, :dependent => :destroy
	has_many :proposal_revisions, :dependent => :destroy
	has_many :proposal_resumes, :dependent => :destroy
  has_many :project_hires, :class_name => 'ProjectHire', :foreign_key => 'proposal_id'
	MAX_LIMIT = 5
	MIN_LIMIT = 2

	def filmmaker_name
		self.filmmaker.name
	end

	def create_proposal_milestones milestones_data
		milestones_data.each do |milestone|
			temp_date = milestone[:date].split('/')
			milestone[:date] = [temp_date[2], temp_date[0], temp_date[1]].join("-")
			unless (milestone[:title].blank? || milestone[:date].blank? || milestone[:amount].blank?)
		    attributes = {:name => milestone[:title],
									    :delivery_date => milestone[:date],
									    :amount => milestone[:amount]}
		    self.project_proposal_milestones.create(attributes)
		  end
	  end
	end

	def create_proposal_revisions user, desc
	   puts user.inspect
	   last_revision = self.proposal_revisions.blank? ? "" : self.proposal_revisions.last.revision_count
	   puts last_revision.inspect
     revision = self.proposal_revisions.create( revised_by: user.id,
                                    revised_user_type: user.class.name.downcase,
                                    revision_count: last_revision.blank? ? 1 : (last_revision.to_i + 1),
                                    description: desc )
    revision
	end

	# TODO: Remove this method later on
	def create_modified_proposal_milestones milestones_data
	  count = self.updated_project_proposal_milestones.collect(&:revision_count).uniq.last
		milestones_data.each do |milestone|
			temp_date = milestone[:date].split('/')
			milestone[:date] = [temp_date[2], temp_date[0], temp_date[1]].join("-")
			unless (milestone[:title].blank? || milestone[:date].blank? || milestone[:amount].blank?)
		    attributes = {:name => milestone[:title],
									    :delivery_date => milestone[:date],
									    :amount => milestone[:amount],
									    :revision_count => count.blank? ? 1 : (count + 1) }
		    self.updated_project_proposal_milestones.create(attributes)
		  end
	  end
	  #self.update_attribute(:is_modified, true) unless self.updated_project_proposal_milestones.blank?
    if self.updated_project_proposal_milestones.present?
      if self.update_attribute(:is_modified, true)
        begin
          project = self.project
          client = project.client if project.present?
          filmmaker = self.filmmaker
          message = 'Your proposal has been changed'
          if project.present? && client.present? && filmmaker.present?
            content = ApplicationController.new.render_to_string( layout: false, partial: "filmmakers/updated_proposal_content", locals: { project_proposal: self })
            client.send_message(filmmaker, content, message)
          end
        rescue Exception => e
          Rails.logger.debug "\n Exception: #{e.inspect}\n"
        end
      end
    end
	end
end

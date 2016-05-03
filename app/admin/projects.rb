ActiveAdmin.register Project do
  index do
    column :title
    column :description
    column :location
    column :compensation
    column :skills do |project|
      "#{project.skills.join(', ') rescue nil}"
    end
    column :price do |project|
      "#{ '$' + project.price.to_s if project.price.present? }"
    end
    column :is_featured, label: 'Featured?'
    column :featured_payment_status, label: 'Featured project payment'
    column :created_at
    default_actions
  end

  filter :title
  filter :description

  form :partial => 'form'

  show do |project|
    panel "Project Details" do
      table_for [project] do
        column("ID"){ project.id }
        column('TITLE'){ project.title }
        column('DESCRIPTION'){ project.description }
        column('CREATED BY'){ project.client.name if project.client.present? }
        column('STATUS'){ project.status }
        column('FEATURED'){ project.featured }
        column('LOCATION'){ project.location }
        column('LATITUDE'){ project.latitude }
        column('LONGITUDE'){ project.longitude }
        column('COMPENSATION'){ project.compensation }
        column('HEADLINE'){ project.headline }
        column('SKILLS'){ project.skills.join(', ') if project.skills.present? && project.skills.is_a?(Array) }
        column('PRICE'){ "$ #{project.price}" }
        column('IS FEATURED'){ project.is_featured }
        column('FEATURED PAYMENT STATUS'){ project.featured_payment_status }
        column('CREATED AT'){ project.created_at }
      end
    end
    panel "Project Questions" do
      table_for project.project_questions do
        column "Question" do |project_question| project_question.question_text end
        column "Answer" do |project_question| project_question.answer_text end
      end
    end
    panel "Project Attachments" do
      table_for project.project_attachments do
        column "Attachment" do |project_attachment| project_attachment.attachment end
      end
    end
    panel "Project Proposals" do
      table_for project.project_proposals do
        column "Cover Letter" do |project_proposal| project_proposal.cover_letter end
        column "Desired Start Date" do |project_proposal| project_proposal.desired_start_date end
        column "Desired End Date" do |project_proposal| project_proposal.desired_end_date end
        column "Filmmaker" do |project_proposal| project_proposal.filmmaker.name end
        column "Approved?" do |project_proposal| project_proposal.is_approved end
        column "Declined?" do |project_proposal| project_proposal.is_declined end
        column "Deleted?" do |project_proposal| project_proposal.is_delete end
        column "Milestones Count" do |project_proposal|
          if project_proposal.is_modified && !project_proposal.proposal_revisions.blank?
            last_revision = project_proposal.proposal_revisions.last
            milestones = last_revision.updated_project_proposal_milestones
          else
            milestones = project_proposal.project_proposal_milestones
          end
          milestones.count
        end
        column "Milestones Amount" do |project_proposal|
          if project_proposal.is_modified && !project_proposal.proposal_revisions.blank?
            last_revision = project_proposal.proposal_revisions.last
            milestones = last_revision.updated_project_proposal_milestones
          else
            milestones = project_proposal.project_proposal_milestones
          end
          milestones.blank? ? "$ 0" : "$ #{milestones.collect(&:amount).sum}"
        end
        column "Created at" do |project_proposal| project_proposal.created_at end
      end
    end
  end
end
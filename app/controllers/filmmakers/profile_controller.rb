class Filmmakers::ProfileController < ApplicationController

  before_filter :authenticate_filmmaker!, :except => 'filmmaker_selection'
  before_filter :authenticate_client!, :only => 'filmmaker_selection'
  helper_method :filmmaker_name, :skills_list

  def index
    @filmmaker = current_filmmaker
    #@projects_done = 0
    #@projects_hired_for = ProjectHire.where(:filmmaker_id => @filmmaker.id)
    #unless @projects_hired_for.empty?
      #proposed_proposals = ProjectProposal.where(:id => @projects_hired_for.pluck(:proposal_id))
      #proposed_proposals.each { |proposal| @projects_done+= 1 if proposal.project.is_complete? }
    #end
    @reviews_data = {}
    @reviews_data[:reviews] = []
    filmmaker_feedbacks = @filmmaker.filmmaker_feedbacks
    project_ids = filmmaker_feedbacks.pluck(:project_id).uniq if filmmaker_feedbacks.present?
    @reviews_data[:total_reviews] = project_ids.count if project_ids.present?
    @reviews_data[:total_reviews] = 0 if @reviews_data[:total_reviews].blank?
    if @reviews_data[:total_reviews] > 0
      project_ids.each do |p_id|
        review_details = {}
        project_feedbacks = filmmaker_feedbacks.where(:project_id => p_id)
        client = project_feedbacks.last.client if project_feedbacks.present?
        rating_by_client = project_feedbacks.average(:rating).round if project_feedbacks.present?
        review_details[:client_details]  = {
          :name => "#{client.name rescue nil}",
          :location => "#{client.location rescue nil}",
          :rating => "#{rating_by_client rescue nil}",
          :id => "#{client.id rescue nil}"
        }
        review_details[:feedback_details] = { :comment => "#{project_feedbacks.where(:attribute_key => 'comment').first.attribute_value rescue nil}",
                                              :created_at => "#{project_feedbacks.last.created_at rescue nil}",
                                              :quality_of_work => "#{project_feedbacks.where(:attribute_key => 'quality_of_work').first.rating rescue nil}",
                                              :attitude => "#{project_feedbacks.where(:attribute_key => 'attitude').first.rating rescue nil}",
                                              :responsiveness => "#{project_feedbacks.where(:attribute_key => 'responsiveness').first.rating rescue nil}",
                                              :experience => "#{project_feedbacks.where(:attribute_key => 'experience').first.rating rescue nil}",
                                              :on_budget => "#{project_feedbacks.where(:attribute_key => 'on_budget').first.rating rescue nil}",
                                              :on_time => "#{project_feedbacks.where(:attribute_key => 'on_time').first.rating rescue nil}"

        }
        reviewed_project = project_feedbacks.last.project if project_feedbacks.present?
        review_details[:project_details] = {
          :project_type => "#{reviewed_project.project_questions.where(:question_text => 'What type of video do you want?').first.answer_text rescue nil}",
          :client_type => "#{client.role rescue nil}",
          :days_left => "#{reviewed_project.proposal_due_days rescue nil}",
          :thought => "#{reviewed_project.description rescue nil}",
          :price => "#{reviewed_project.price rescue nil}"
        }
        @reviews_data[:reviews] << review_details
      end
    end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @filmmaker }
    end
  end

  def filmmaker_selection
    @filmmaker = Filmmaker.find(params[:filmmaker_id])
    render :layout => 'dialog'
  end

	def filmmaker_name
    if @filmmaker.is_company == true
      return @filmmaker.company
    else
      return @filmmaker.name
    end
  end

  def skills_list
    if @filmmaker.skills.present?
      @filmmaker.skills.split(',').collect(&:strip)
    else
      ["No Skills Entered"]
    end
  end
end

class Filmmakers::FeedbackController < ApplicationController
   before_filter :require_user

   def index
     @project = Project.find_by_id(params[:project_id]) 
     @project_questions = @project.project_questions.where("question_text in (?)", ["About how long do you want it to be?", "Proposals due by", "Who do you want applicants by?", "What type of video do you want?"]).order('id asc')
     if current_filmmaker
       @filmmaker = current_filmmaker 
       @feedback_attributes = FilmmakerFeedback::CLIENT_FEEDBACK_ATTRIBUTES
       @feedbacks = ProjectFeedback.where(:filmmaker_id => current_filmmaker.id, :project_id => params[:project_id]).first
       redirect_url = "/filmmakers/dashboard"
     else
       @feedback_attributes = FilmmakerFeedback::FILMMAKER_FEEDBACK_ATTRIBUTES
       @feedbacks = FilmmakerFeedback.where(:client_id => current_client.id,:project_id => params[:project_id]).order("created_at asc")
       project_proposals = @project.project_proposals
       if project_proposals.blank? 
         redirect_to "/clients/dashboard" and return if @project.direct_hire_proposals.where(is_approved: true).blank?
         @filmmaker = @project.direct_hire_proposals.where(is_approved: true).first.filmmaker 
       else 
         @filmmaker = project_proposals.where(is_approved: true).first.filmmaker
       end
       redirect_url = "/clients/dashboard"
     end   
     if !(@feedbacks.blank?)
       redirect_to redirect_url
     else 
       respond_to do |format|
         format.html # index.html.erb
         format.json { render json: @filmmakers }
       end
     end
   end

    # Client's feedback submission action
    def submit_feedback
	    if current_client 
	      project = Project.find_by_id(params[:project_id])
    	  feedback_available = FilmmakerFeedback.exists?(:client_id => current_client.id, :project_id => params[:project_id], :filmmaker_id => params[:filmmaker_id])
    	  if feedback_available
    		  feedbacks = FilmmakerFeedback.where(:client_id => current_client.id, :project_id => params[:project_id])
    		  symbolic_attributes = FilmmakerFeedback::FILMMAKER_FEEDBACK_ATTRIBUTES.map{|e| e.downcase.tr(" ","_")}
    		  params[:feedback].merge!(:comment => params[:comment])
    
    		  feedbacks.each do |feedback|
    			  if feedback.attribute_key.in?(symbolic_attributes) && !feedback.attribute_key.eql?('comment')
    			    feedback.update_attributes(:rating => params[:feedback]["#{feedback.attribute_key}"].to_i)
    			  elsif feedback.attribute_key.in?(symbolic_attributes) && feedback.attribute_key.eql?('comment')
    			    feedback.update_attributes(:attribute_value => params[:feedback][:comment])
    			  end
    		   end
    	  else
    		  params[:feedback].merge!(:comment => params[:comment])
    		  params[:feedback].each do |key, value|
    			  feedback 		   = FilmmakerFeedback.new
    			  feedback.attribute_key   = key
    			  feedback.attribute_value = key.eql?('comment') ? params[:feedback][:comment] : key.tr("_", " ").split(' ').map(&:capitalize).join(" ")
    			  feedback.rating 	   = value.to_i unless key.eql?('comment')
    			  feedback.client_id	   = current_client.id
    			  feedback.filmmaker_id	   = params[:filmmaker_id]
    			  feedback.project_id	   = params[:project_id]
    			  feedback.save
    		  end
    	  end
        redirect_to '/clients/dashboard'
    	else
        project = Project.find_by_id(params[:feedback][:project_id])
    	  ProjectFeedback.set_filmmaker_feedback(params)
        redirect_to client_path(project.client) 
    	end   
    end

end

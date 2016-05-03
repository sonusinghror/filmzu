module ProjectsHelper

	def file_name(upload)
   (upload.attachment? && upload.attachment.file.present?) ? upload.attachment.file.filename : "Attachment"
	end

  def display_proposal_button(project)
    display = false
    proposal_submitted = project.project_proposals.where("filmmaker_id = ?",current_filmmaker.id)
    time_left = ((((project.created_at + project.project_details.second.split(" ").first.to_i.days) - Time.now).to_i) / 3600 ) rescue 0
    location_preference = project.location.blank? ? true : project.location == current_filmmaker.location
    #project_skills = project.skills.split(",").map(&:downcase) rescue []
    filmmaker_skills = current_filmmaker.skills.split(",").map(&:downcase) rescue []
    #skills_preference = project_skills.empty? ? true : (project_skills - filmmaker_skills).empty?
    #if (proposal_submitted.empty?) && !(project.as_hire?) && (location_preference) && (time_left != 0)# && (skills_preference)
    if (proposal_submitted.empty?) && (time_left != 0) #&& !(project.as_hire?)
      display = true
    end
    [display,!(proposal_submitted.empty?)]
  end

  def project_rating(project_feedbacks)
    unless project_feedbacks.blank?
      sum = ( ( ( project_feedbacks.collect(&:total_rating).sum.to_f / (25 * project_feedbacks.count).to_f ) ) * 5.0).round 
    else
      sum = 0
    end
    sum
  end  

  def days_left(count)
    if (count < 0)
      "<span>Closed</span>"
    else
      "<span>#{count} d</span> Left"
    end
  end  

  def display_feedback_button(project)
    FilmmakerFeedback.where("project_id = ? AND client_id = ?",project.id,current_client.id).first.blank? && !(current_client.projects.where("id = ?",project.id).first.blank?)
  end  

end
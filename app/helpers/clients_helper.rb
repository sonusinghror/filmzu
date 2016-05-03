module ClientsHelper
  def authenticate_client!
    authenticate_user!
    unless current_user.type == "Client"
      redirect_to "/", :alert => "You need to be signed in as Client to see this page"
    end
  end

  def is_active(navigation_link)
    (request.original_url == navigation_link) ? 'active' : ''
  end

  def display_project_feedback_filmmaker(project)
    project_proposals = project.project_proposals
    dr_project_proposals = project.direct_hire_proposals
    proposal = project.project_proposals.blank? ? dr_project_proposals.where("filmmaker_id = ?",current_filmmaker.id) : project.project_proposals.where("filmmaker_id = ?",current_filmmaker.id)
    ProjectFeedback.where("project_id = ? AND filmmaker_id = ?",project.id,current_filmmaker.id).first.blank? && proposal.first.try(:is_approved)
  end

  def display_project_feedback_client(project)
    project.client == current_client && FilmmakerFeedback.where(:project_id => project.id, :client_id => current_client.id).blank?
  end

  def star_rating(client_feedbacks)
    unless client_feedbacks.blank?
      sum = ( ( ( client_feedbacks.collect(&:total_rating).sum.to_f / (25 * client_feedbacks.count).to_f ) ) * 5.0).round
    else
      sum = 0
    end
    "star-#{sum}.png"
  end

end

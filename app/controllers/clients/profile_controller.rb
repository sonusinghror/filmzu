class Clients::ProfileController < ApplicationController

  before_filter :authenticate_client!, :except => [:show]

  def index
    @client = current_client
    @feedback_projects = ProjectFeedback.filmamker_feedback_projects(current_client)
    @projects = @client.projects
    @client_feedbacks = @client.project_feedbacks
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @clients }
    end
  end
  
  def show
    @client = Client.find(params[:id])
  end
  
  
end


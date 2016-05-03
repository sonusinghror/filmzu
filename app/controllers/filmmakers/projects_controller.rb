class Filmmakers::ProjectsController < ApplicationController

  before_filter :authenticate_filmmaker!

  def index
    @filmmaker = current_filmmaker
    @all_projects = current_filmmaker.own_projects
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @filmmakers }
    end
  end

  def filmmaker_proposals
    if params.has_key?(:proposal_id)
      @project_proposals = ProjectProposal.where("(id = ? AND filmmaker_id = ?) AND (is_delete = ?)",url_decode(params[:proposal_id]),current_filmmaker.id,false)
    else
      #@project_proposals = ProjectProposal.find(params[:proposal_id])
      @project_proposals = ProjectProposal.where("filmmaker_id = ? AND is_delete = ?",current_filmmaker.id,false)
    end
  end

  def accept_updated_proposal
    proposal = ProjectProposal.find(params[:proposal_id])
    if proposal.update_attributes(:is_approved => true, :is_declined => false)
      ProjectHire.hire_filmmaker proposal, "filmmaker"
    end
    respond_to do |format|
     format.js
     format.html { redirect_to :back }
    end
  end

  def decline_updated_proposal
    proposal = ProjectProposal.find(params[:proposal_id])
    proposal.update_attributes(:is_declined => true, :is_approved => false)
    client = proposal.project.client
    if current_filmmaker.present? && client.present?
      current_filmmaker.send_message(client, "Your proposal has been rejected for #{proposal.project.title rescue nil}", 'Your proposal has been rejected')
    end
    respond_to do |format|
     format.js
     format.html { redirect_to :back, alert: "Your proposal has been rejected!" }
    end
  end

  def edit_updated_proposal
    @project_proposal = ProjectProposal.find(params[:proposal_id])
    @project = @project_proposal.project
	  @client_details = @project.client_details
	  @proposal_details = @project.new_proposal_details @project_proposal.filmmaker_id
	  @proposal = @project.project_proposals.build
	  @filmmaker = Filmmaker.find(@project_proposal.filmmaker_id)
    render :layout => 'dialog'
  end

end

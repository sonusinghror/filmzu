class DisputesController < ApplicationController
  # GET /disputes
  # GET /disputes.json
  def index
    @disputes = Dispute.all
    @proposed_projects = current_client ? current_client.proposed_projects : Array.new
    if @proposed_projects.empty? && !current_client && current_filmmaker
      @proposed_projects = ProjectProposal.includes(:project).where("id in (?)",current_filmmaker.project_hires.pluck(:proposal_id))
    end
    if current_client
      if current_client.project_hires.present?
        @disputed_projects = Dispute.where(:proposal_id => ProjectProposal.includes(:project).where("id in (?)",current_client.project_hires.pluck(:proposal_id)))
      else
      end
    elsif current_filmmaker
      if current_filmmaker.project_hires.present?
        @disputed_projects = Dispute.where(:proposal_id => ProjectProposal.includes(:project).where("id in (?)",current_client.project_hires.pluck(:proposal_id)))
      else
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @disputes }
    end
  end

	def disputedetails

	render :layout => 'popup'
	end

  # GET /disputes/1
  # GET /disputes/1.json
  def show
    @dispute = Dispute.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @dispute }
    end
  end

  # GET /disputes/new
  # GET /disputes/new.json
  def new
    @dispute = Dispute.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @dispute }
    end
  end

  # GET /disputes/1/edit
  def edit
    @dispute = Dispute.find(params[:id])
  end

  # POST /disputes
  # POST /disputes.json
  def create
    
    to_go = current_filmmaker ? "filmmakers" : "clients"
    
    @dispute = Dispute.new(:dispute_description=> params[:dispute][:dispute_description], :proposal_id => params[:dispute][:proposal_id])

    respond_to do |format|
      if @dispute.save
	
	if params[:proposal_attachment].present?
	  @dispute.dispute_attachments.create(:attachment => params[:proposal_attachment])
	end
	
        format.html { redirect_to "/#{to_go}/disputes", notice: 'Dispute was successfully created.' }
        format.json { render json: @dispute, status: :created, location: @dispute }
      else
        format.html { render action: "new" }
        format.json { render json: @dispute.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /disputes/1
  # PUT /disputes/1.json
  def update
    @dispute = Dispute.find(params[:id])

    respond_to do |format|
      if @dispute.update_attributes(params[:dispute])
        format.html { redirect_to @dispute, notice: 'Dispute was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @dispute.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /disputes/1
  # DELETE /disputes/1.json
  def destroy
    @dispute = Dispute.find(params[:id])
    @dispute.destroy

    respond_to do |format|
      format.html { redirect_to disputes_url }
      format.json { head :no_content }
    end
  end
end

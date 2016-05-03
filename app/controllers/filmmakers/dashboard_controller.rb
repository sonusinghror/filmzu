class Filmmakers::DashboardController < ApplicationController

  before_filter :authenticate_filmmaker!

  def index
    @filmmaker = current_filmmaker
    @open = Project.where('created_at >= :ten_days_ago AND user_id IS NOT NULL',:ten_days_ago  => Time.now - 10.days)
    @projects = @open.exclude_blacklisted_projects current_filmmaker
    @projects = Kaminari.paginate_array(@projects).per_page_kaminari(params[:page]).per(10)
    #@projects = @projects.sort_by(&:"#{sort_column}")
    #@projects = @projects.reverse if sort_direction == 'DESC'
    #@projects= Kaminari.paginate_array(@projects).per_page_kaminari(1).per(10)

    flash[:notice] = "Welcome to the Dashboard " + @filmmaker.name
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @filmmakers }
    end
  end

	def proposal_submitted
	  project_id = url_decode(params[:project_id])
	  filmmaker_id = url_decode(params[:filmmaker_id])
	  @project = Project.find(project_id)
	  @client_details = @project.client_details
	  @proposal_details = @project.new_proposal_details filmmaker_id
	  @proposal = @project.project_proposals.build
	  render :layout => 'dialog'
	end

	def proposal_submitted1
	  @proposal = ProjectProposal.find(url_decode(params[:proposal_id]))
	  @projectid = @proposal.project_id
	  render :layout => 'popup'
	  FilmmakerMailer.delay.proposal_submitted_confirmation(current_filmmaker, @projectid)
	  ClientMailer.delay.proposal_received(Client.find(Project.find(@projectid).user_id), @projectid)
	end

	# invisible the project from listing
	def blacklist_project
		current_filmmaker.blacklist_project(params[:project_id], current_filmmaker.id)
		redirect_to :back
	end

	def switch_pro
		if request.get?
			@client = current_filmmaker
		elsif request.post?
			client = current_filmmaker
			pro_account = client.pro_account
			if params[:account_type] == 'pro'
  			status, msg = current_filmmaker.make_first_pro_account_transaction
			  if status
			    if pro_account
				    current_filmmaker.pro_account.update_attributes(:account_type => params[:account_type], :payment_at => Time.now)
			    else
			      pro_account = ProAccount.new(:accountable_id => current_filmmaker.id,
			                                   :accountable_type => 'Filmmaker',
			                                   :account_type => params[:account_type],
			                                   :payment_at => Time.now)
				    pro_account.save!
			    end
			    flash[:success] = msg
		    else
			    flash[:error] = msg
		    end
			else
	      if pro_account
		      current_filmmaker.pro_account.update_attributes(:account_type => params[:account_type])
	      else
	        pro_account = ProAccount.new(:accountable_id => current_filmmaker.id, :accountable_type => 'Filmmaker', :account_type => params[:account_type])
		      pro_account.save!
	      end
	      flash[:success] = "Your account has been changed to standard account"
			end
			redirect_to '/filmmakers/accounts'
		end
	end

private
  def sort_column
    Project.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def sort_direction
    %w[desc asc].include?(params[:direction]) ? params[:direction] : "DESC"
  end
end

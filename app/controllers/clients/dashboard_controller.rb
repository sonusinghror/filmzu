class Clients::DashboardController < ApplicationController

  before_filter :authenticate_client!
	layout 'application'
	#before_filter :create_lazy_project, :only => 'index'
  before_filter :create_lproject_from_session, only: 'index'

  def index
    client = current_client
    @projects = client.recent_projects(params)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @clients }
    end
  end

  def create_project
    render :layout => 'popup'
  end

  def create_lproject_from_session
    lazy = session[:lazy]
    project_id = session[:project_id]
    is_featured = session[:featured]
    session[:lazy_featured_project] = true if ['true', true].include?(is_featured)
    if project_id.present?
      project = Project.where('ip_address=? AND user_id IS NULL', request.remote_ip).last
      return if project.blank?
      project.update_attributes(:user_id => current_client.id)
      [:lazy, :project_id, :featured].each do |ss|
        session[ss] = nil
      end
      p "=BEFORE JOB STARTED="
      BalancedJob.new.async.create_marketplace_customer(current_client)
      p "=AFTER JOB COMPLETION="
      ProjectMailer.delay.project_confirmation(project)
      p "=MAILER PROJECT SENT="
    end
  end

	def create_lazy_project
	  if request.referer.present?
  		referer = request.referer.split("&")
  		prj_id=0
  		session[:lazy_featured_project] = true if referer.last.include?('featured')
  		if (referer.last.to_s.include?('prj') || referer[-2].to_s.include?('prj'))
  			project = Project.where("ip_address = ? and user_id IS NULL", request.remote_ip).last
  			return if project.nil?
  			project.update_attributes(:user_id => current_client.id)
  			prj_id= referer.select{|e| e if e.include? 'prj'}.first.split("=").last.to_i
  			p "=BEFORE JOB STARTED="
  			BalancedJob.new.async.create_marketplace_customer(current_client)
  			p "=AFTER JOB COMPLETION="
  		end
  		redirect_to '/clients/accounts?prj='+prj_id.to_s if session.has_key?(:lazy_featured_project)
	  end
	end

	def switch_pro
		if request.get?
			@client = current_client
		elsif request.post?
			client = current_client
			pro_account = client.pro_account
			if pro_account
				current_client.pro_account.update_attributes(:account_type => params[:account_type])
				client_credit_card = Balanced::Card.fetch(current_client.credit_cards.last.credit_card_uri)
				client_credit_card.debit(
          :amount => 9,
					:description => 'Your account is upgraded now!'
			  )
			else
				current_client.pro_account.create(:account_type => params[:account_type])
			end
			redirect_to '/clients/dashboard'
		end
	end
end

class ClientsController < ApplicationController

 # layout :client

 # before_filter :verify_client, :except=>[:search_location, :store_project_data]
  before_filter :authenticate_client!, :except=>[:search_location, :store_project_data, :show]
  before_filter :set_page_title, :except=>[:search_location, :store_project_data]

  def store_project_data
	  project_id = Project.create_new_project params, request.remote_ip, nil
	  redirect_str = '/clients/sign_up?lazy=1&prj='+project_id.to_s
	  redirect_str = redirect_str+"&featured=true" if params[:is_featured].to_s == "true"
	  redirect_to redirect_str, notice: "Thanks for those details, now let's get you a login and password."
  end

  def create_direct_hire_proposal
    temp_start_date = params[:proposal][:desired_start_date].split('/')
    params[:proposal][:desired_start_date] = [temp_start_date[2], temp_start_date[0], temp_start_date[1]].join("-")
    temp_end_date = params[:proposal][:desired_end_date].split('/')
    params[:proposal][:desired_end_date] = [temp_end_date[2], temp_end_date[0], temp_end_date[1]].join("-")
    direct_hire_proposal = current_client.direct_hire_proposals.new params[:proposal]
    direct_hire_proposal.is_approved = false
    direct_hire_proposal.is_declined = false
    filmmaker = Filmmaker.find(params[:proposal][:filmmaker_id])
    respond_to do |format|
			if direct_hire_proposal.save
					direct_hire_proposal.create_direct_hire_proposal_milestones params[:milestones]
					content = render_to_string( layout: false, partial: "/clients/proposal_content", locals: { direct_hire_proposal: direct_hire_proposal })
					#current_client.send_message(filmmaker, direct_hire_body_content(direct_hire_proposal), "Direct Hire")
					response = current_client.send_message(filmmaker, content, "Direct Hire")
					if response.present? && !response.notification_id.blank?
					  message = Message.find(response.notification_id)
					  direct_hire_proposal.update_attribute(:conversation_id, message.conversation.id)
					end
					format.html { redirect_to '/filmmakers', notice: 'Proposal was submitted successfully.' }
			else
					format.html {redirect_to :back}
			end
		end
  end

  def set_page_title
    @page_title = "Clients on Filmzu"
  end

  def dashboard
    @client = current_client
    redirect_to clients_dashboard_url
  end

  def verify_client
    :authenticate_user!
    redirect_to root_url unless has_role?(current_client, 'client')

  end

  def current_ability
    @current_ability ||= ClientAbility.new(current_client)
  end

	def change_password
    if !current_client.valid_password? params[:currentPassword]
      @errors = "Invalid password."
    else
      if !current_client.reset_password!(params[:password], params[:confirmPassword])
        @errors = current_client.errors.full_messages
      else
        sign_in(current_client, :bypass => true)
      end
    end
    respond_to do |format|
      format.js #change_password.js.erb
    end
  end

  def change_email
    current_client.update_attributes email: params[:newEmail]
    respond_to do |format|
      format.js #change_email.js.erb
    end
  end

  def change_email_settings
    current_client.update_attributes send_notification_mails: params[:client][:send_notification_mails]
    respond_to do |format|
      format.js #change_email_settings.js.erb
    end
  end

  # GET /clients
  # GET /clients.json

  def step_1
    respond_to do |format|
    format.html
  end
 end

  def search_messages
    redirect_to clients_messages_path and return if params[:search].blank? && request.post?
    
    messages = []
    current_client.mailbox.conversations.each {|conv| messages << conv.messages.reject{|msg| (msg.subject == "Project Proposal") || !(msg.subject.match(/#{params[:search]}/) || msg.body.match(/#{params[:search]}/)) } }
    messages_list = messages.flatten!    
    
    @messages = Kaminari.paginate_array(messages_list).per_page_kaminari(params[:page]).per(5)
    @conversation = @messages.first    
  end


  def index
    @clients = Client.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @clients }
    end

    # if params[:query].present?
    #   @clients = Client.search(params[:query], page: params[:page])
    # else
    #   @clients = Client.all.page params[:page]
    # end
  end

  # GET /clients/1
  # GET /clients/1.json
  def show
    @client = Client.find(params[:id])
    @projects = @client.projects
    @client_feedbacks = @client.project_feedbacks
    @feedback_projects = ProjectFeedback.filmamker_feedback_projects(@client)
  end

  # GET /clients/new
  # GET /clients/new.json
  def new
    @client.build_profile
    @client = Client.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @client }
    end
  end

  # GET /clients/1/edit
  def edit
    @client = Client.find(params[:id])
  end

  # POST /clients
  # POST /clients.json
  def create
    @user = User.new(params[:user])
    @client = Client.new(params[:client])
    @user.meta = @client
    @client.save
    @user.save
    sign_in_and_redirect @user
    super
    ClientMailer.welcome(@client).deliver unless @client.invalid?
    end

    respond_to do |format|
      if @client.save
        format.html { redirect_to @client, notice: 'Client was successfully created.' }
        format.json { render json: @client, status: :created, location: @client }
      else
        format.html { render action: "new" }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /clients/1
  # PUT /clients/1.json
  def update
    @client = Client.find(params[:id])

    respond_to do |format|
      if @client.update_attributes(params[:client])
        format.html { redirect_to @client, notice: 'Client was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /clients/1
  # DELETE /clients/1.json
  def destroy
    @client = Client.find(params[:id])
    @client.destroy

    respond_to do |format|
      format.html { redirect_to clients_url }
      format.json { head :no_content }
    end

  end

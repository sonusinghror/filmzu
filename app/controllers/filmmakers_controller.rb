class FilmmakersController < ApplicationController

  before_filter :verify_filmmaker
  before_filter :set_page_title
  helper_method :user_signed_in?, :filmmaker_name, :skills_list, :sort_column, :sort_direction


  def set_page_title
    @page_title = "Filmmakers on Filmzu"
  end

  def verify_filmmaker
    :authenticate_user!
    # redirect_to root_url unless has_role?(current_user, 'filmmaker')
  end

  def current_ability
    @current_ability ||= FilmmakerAbility.new(current_user)
  end

 def submit_proposal
   temp_start_date = params[:proposal][:desired_start_date].split('/')
   params[:proposal][:desired_start_date] = [temp_start_date[2], temp_start_date[0], temp_start_date[1]].join("-")
   temp_end_date = params[:proposal][:desired_end_date].split('/')
   params[:proposal][:desired_end_date] = [temp_end_date[2], temp_end_date[0], temp_end_date[1]].join("-")
	 project_proposal = current_filmmaker.project_proposals.new(params[:proposal])
	 project_proposal.project_id = params[:project_id]
   client = project_proposal.project.client
	 respond_to do |format|
		 if project_proposal.save
		   if params[:proposal_attachment].present?
		     project_proposal.proposal_resumes.create(:attachment => params[:proposal_attachment])
		   end
		   project_proposal.create_proposal_milestones	params[:milestones]
       content = render_to_string( layout: false, partial: "/filmmakers/proposal_content", locals: { project_proposal: project_proposal })
       response = current_filmmaker.send_message(client, content, "Project Proposal")
       if response.present? && !response.notification_id.blank?
         message = Message.find(response.notification_id)
         project_proposal.update_attribute(:conversation_id, message.conversation.id)
       end
		   format.html { redirect_to view_project_path(url_encode(params[:project_id]), :n=>1, :pid => url_encode(project_proposal.id)) }
		 else
		   format.html {redirect_to :back}
		 end
	 end
 end

  # # TODO: Remove this method later on
  def modify_project_proposal1
     project_proposal = ProjectProposal.find(params[:project_proposal_id])
     if project_proposal.present?
       #conversation = Conversation.find(project_proposal.conversation_id)
       revison = project_proposal.create_proposal_revisions current_filmmaker, params[:description]
       if revison.present?
         revison.create_modified_proposal_milestones	params[:milestones]
       end
       content = render_to_string( layout: false, partial: "/filmmakers/proposal_content", locals: { project_proposal: project_proposal })
       #current_client.reply_to_conversation(conversation, content)
       #redirect_to :back
     end
     redirect_to :back, notice: "Proposal has been modified!"
  end

	def change_password
    if !current_filmmaker.valid_password? params[:currentPassword]
      @errors = "Invalid password."
    else
      if !current_filmmaker.reset_password!(params[:password], params[:confirmPassword])
        @errors = current_filmmaker.errors.full_messages
      else
        sign_in(current_filmmaker, :bypass => true)
      end
    end
    respond_to do |format|
      format.js #change_password.js.erb
    end
  end

  def change_email
    current_filmmaker.update_attributes email: params[:newEmail]
    respond_to do |format|
      format.js #change_email.js.erb
    end
  end

  def change_email_settings
    current_filmmaker.update_attributes send_notification_mails: params[:filmmaker][:send_notification_mails]
    respond_to do |format|
      format.js #change_email_settings.js.erb
    end
  end

  def change_company_settings
    current_filmmaker.update_attributes is_company: params[:filmmaker][:is_company]
    current_filmmaker.update_attributes company: params[:filmmaker][:company]
    respond_to do |format|
      format.js #change_company_settings.js.erb
    end
  end
  # GET /filmmakers
  # GET /filmmakers.json
  def index
    #ransack filteration of the project
    if params.has_key?(:search_filmmaker) && !params[:search_filmmaker].empty?
      params[:filter] = {}
      params[:filter][:name_cont] = params[:search_filmmaker]
      @request = params[:search_filmmaker]
      @filmmakers = Kaminari.paginate_array(Filmmaker.ransack(params[:filter]).result.order("name ASC")).per_page_kaminari(params[:page]).per(6)
    else
      if !(params[:minimum].blank?) || !(params[:maximum].blank?) || !(params[:location].blank?) || !(params[:skill].blank?)
        params[:filter] = {}
        if params.has_key?(:minimum) || params.has_key?(:maximum)
          @minimum_rate, @maximum_rate = form_rate_range_values(params[:minimum],params[:maximum])
          params[:filter][:rate_gteq], params[:filter][:rate_lteq]  = @minimum_rate, @maximum_rate
        end
        params[:filter][:location_eq] = params[:location] if params.has_key?(:location)
        unless params[:location].blank?
          loc_based_filmmaker = Filmmaker.near(params[:location], params[:miles])
        end
        params[:filter][:skills_cont] = params[:skill] if params.has_key?(:skill)
        params[:filter][:id_not_in] = current_client.project_hires.pluck(:filmmaker_id) unless current_client.nil? || current_filmmaker.nil?
        #ransack filteration of the project
        if params.has_key?(:search_filmmaker) && !params[:search_filmmaker].empty?
          params[:filter] = {}
          params[:filter][:name_cont] = params[:search_filmmaker]
          @request = params[:search_filmmaker]
          @filmmakers = Kaminari.paginate_array(Filmmaker.ransack(params[:filter][:name_cont]).result.order("name ASC")).per_page_kaminari(params[:page]).per(6)
        else params.has_key?(:filter) && !params[:filter].empty?
          @filter = params[:filter]
          @locat = params[:location]
          @skills = params[:skill]
          if params.has_key?(:minimum) || params.has_key?(:maximum)
            @price = "$"+@minimum_rate.to_s+" - $"+@maximum_rate.to_s
          end
          @search = Filmmaker.ransack(params[:filter])
          total_results = loc_based_filmmaker.blank? ? @search.result.order("created_at DESC") : (@search.result + loc_based_filmmaker).uniq.sort_by(&:created_at).reverse
          @filmmakers = Kaminari.paginate_array(total_results).per_page_kaminari(params[:page]).per(6)
        end
      else
        #@filmmakers = Kaminari.paginate_array(Filmmaker.order("created_at DESC")).per_page_kaminari(params[:page]).per(6)
        @candidates = Filmmaker.where("#{sort_column} IS NOT NULL")
        @filmmakers = Kaminari.paginate_array(@candidates.order(sort_column + ' ' + sort_direction)).per_page_kaminari(params[:page]).per(10)
        if params.has_key?(:sort) && !params[:sort].empty?
          if params[:sort] == "rate"
            @sorted = "Rate"
            @sorteddirection = (params[:direction] == "desc") ? "Highest to Lowest" : "Lowest to Highest"
          else
            if params[:sort] == "created_at"
              @sorted = "age"
              @sorteddirection = (params[:direction] == "desc") ? "with the most recent" : "with the veterans"
            end
          end
          #@sorted = (params[:sort] == "rate") ? "daily rate" : "ascending"
          #@sorteddirection = (params[:direction] == "desc") ? "descending" : "ascending"
        end
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @filmmakers }
    end
  end

  def show
    @filmmaker = Filmmaker.find(params[:id])
    @page_title = filmmaker_name(@filmmaker) + ' | Filmzu Video Production Marketplace'   
    @reviews_data = {}
    @reviews_data[:reviews] = []
    filmmaker_feedbacks = @filmmaker.filmmaker_feedbacks
    project_ids = filmmaker_feedbacks.pluck(:project_id).uniq
    @reviews_data[:total_reviews] = project_ids.count
    if @reviews_data[:total_reviews] > 0
      project_ids.each do |p_id|
        review_details = {}
        project_feedbacks = filmmaker_feedbacks.where(:project_id => p_id)
        last_feedback = project_feedbacks.last if project_feedbacks.present?
        client = last_feedback.client if last_feedback.present? && last_feedback.client.present?
        rating_by_client = project_feedbacks.average(:rating).round
        review_details[:client_details] = { :name => "#{client.name rescue nil}",
                                            :location => "#{client.location rescue nil}",
                                            :rating => rating_by_client,
                                            :id => "#{client.id rescue nil}"}
        review_details[:feedback_details] = { :comment => "#{project_feedbacks.where(:attribute_key => 'comment').first.attribute_value rescue nil}",
                                              :created_at => "#{project_feedbacks.last.created_at rescue nil}",
                                              :quality_of_work => "#{project_feedbacks.where(:attribute_key => 'quality_of_work').first.rating rescue nil}",
                                              :attitude => "#{project_feedbacks.where(:attribute_key => 'attitude').first.rating rescue nil}",
                                              :responsiveness => "#{project_feedbacks.where(:attribute_key => 'responsiveness').first.rating rescue nil}",
                                              :experience => "#{project_feedbacks.where(:attribute_key => 'experience').first.rating rescue nil}",
                                              :on_budget => "#{project_feedbacks.where(:attribute_key => 'on_budget').first.rating rescue nil}",
                                              :on_time => "#{project_feedbacks.where(:attribute_key => 'on_time').first.rating rescue nil}"
        }
        reviewed_project = project_feedbacks.last.project if project_feedbacks.present? && project_feedbacks.last.present?
        review_details[:project_details] = {
          :project_type => "#{reviewed_project.project_questions.where(:question_text => "What type of video do you want?").first.answer_text rescue nil}",
          :client_type => "#{client.role rescue nil}",
          :days_left => "#{reviewed_project.proposal_due_days rescue nil}",
          :title => "#{reviewed_project.title rescue nil}",
          :id => "#{reviewed_project.id rescue nil}",
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

  # GET /filmmakers/new
  # GET /filmmakers/new.json
  def new
    @filmmaker.build_profile
    @filmmaker = Filmmaker.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @filmmaker }
    end
  end

  # GET /filmmakers/1/edit
  def edit
    @filmmaker = Filmmaker.find(params[:id])
  end

  # POST /filmmakers
  # POST /filmmakers.json
  def create
    @user = User.new(params[:user])
    @filmmaker = Filmmaker.new(params[:filmmaker])
    @user.meta = @filmmaker
    @filmmaker.save
    @user.save
    sign_in_and_redirect @user
    super
    FilmmakerMailer.delay.welcome(@filmmaker) unless @filmmaker.invalid?
    respond_to do |format|
     if @filmmaker.save
        format.html { redirect_to @filmmaker, notice: 'Filmmaker was successfully created.' }
        format.json { render json: @filmmaker, status: :created, location: @filmmaker }
      else
        format.html { render action: "new" }
        format.json { render json: @filmmaker.errors, status: :unprocessable_entity }
     end
    end
  end

  # PUT /filmmakers/1
  # PUT /filmmakers/1.json
  def update
    @filmmaker = Filmmaker.find(params[:id])

    respond_to do |format|
      if @filmmaker.update_attributes(params[:filmmaker])
        format.html { redirect_to @filmmaker, notice: 'Filmmaker was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @filmmaker.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /filmmakers/1
  # DELETE /filmmakers/1.json
  def destroy
    @filmmaker = Filmmaker.find(params[:id])
    @filmmaker.destroy

    respond_to do |format|
      format.html { redirect_to filmmakers_url }
      format.json { head :no_content }
    end
  end

  def search_messages
    redirect_to filmmakers_messages_path and return if params[:search].blank? && request.post?

    messages = []
    current_filmmaker.mailbox.conversations.each {|conv| messages << conv.messages.reject{|msg| (msg.subject == "Project Proposal") || !(msg.subject.match(/#{params[:search]}/) || msg.body.match(/#{params[:search]}/)) } }
    messages_list = messages.flatten!

    @inbox_messages = Kaminari.paginate_array(messages_list).per_page_kaminari(params[:page]).per(5)
    @conversation = @inbox_messages.first
  end


  def dashboard_conversations
    resp = {}

    resp['inbox_conversations'] = current_filmmaker.mailbox.inbox if params[:type] == 'inbox'
    resp['sent_conversations'] = current_filmmaker.mailbox.sentbox if params[:type] == 'sent'
    resp['trash_conversations'] = current_filmmaker.mailbox.trash if params[:type] == 'trash'

    respond_to do |format|
      format.html { redirect_to root_url }
      format.json {
        render :json => resp.to_json(:check_user => current_filmmaker)
      }
    end
  end

  def portfolio
    if @filmmaker.update_attributes(params[:filmmaker])
      format.html { redirect_to @filmmaker, notice: 'Filmmaker portfolio  was successfully updated.' }
      format.json { head :no_content }
    else
      format.html { render action: "edit" }
      format.json { render json: @filmmaker.errors, status: :unprocessable_entity }
    end
  end

  def filmmaker_name(filmmaker)
    if filmmaker.is_company == true
      return filmmaker.company
    else
      return filmmaker.name
    end
  end

  def skills_list
    if @filmmaker.skills.present?
      @filmmaker.skills.split(',').collect(&:strip)
    else
      ["No Skills Entered"]
    end
  end

  def form_rate_range_values(minimum,maximum)
    if !(minimum.blank?) && !(maximum.blank?)
      values = [minimum,maximum]
    else
      if !(minimum.blank?) && maximum.blank?
        values = [minimum,350]
      end
      if minimum.blank? && !(maximum.blank?)
        values = [10,maximum]
      end
    end
    values
  end

  private
  def sort_column
    #params[:sort] || "created_at"
    Filmmaker.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : "desc"
  end

end

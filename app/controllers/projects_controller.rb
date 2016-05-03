class ProjectsController < ApplicationController

  load_and_authorize_resource :except => [:show, :view_project, :download_additional_docs, :modify_project_proposal]
  after_filter :clear_temp_photo_objects, :only => [:update, :create]
  before_filter :set_page_title
  helper_method :sort_column, :sort_direction


  def set_page_title
    @page_title = "Projects on Filmzu Video Production Marketplace"
  end

  def index
    #ransack filteration of the project
    param_values = params.values_at(*Project::PROJECT_PARAMS).compact!
    dr_projects = DirectHire.all_direct_hire_projects
    if !(param_values.blank?)
      @filter = params[:filter]
      params[:type], params[:filter] = {}, {}
      unless params[:client_name].blank?
        client_text = "client name " + params[:client_name]
        clients = Client.ransack({:name_cont => params[:client_name]}).result
        user_ids = clients.collect(&:projects).flatten.collect(&:user_id)
        params[:filter][:user_id_in] = user_ids.blank? ? ["NULL"] : user_ids
      end
      unless params[:description].blank?
        description_text = "project description " + params[:description]
        params[:filter][:description_cont] = params[:description]
      end
      check_filter_values = params.values_at(*Project::CHECK_FILTER_PARAMS).compact!
      unless check_filter_values.blank?
        check_filter_text = check_filter_values.join(" ")
        project_ids = ProjectQuestion.ransack({:answer_text_in => check_filter_values}).result.order('answer_text ASC').map(&:project_id)
        project_ids = project_ids.blank? ? ["NULL"] : project_ids
        params[:filter][:id_in] =  project_ids
      end
      if params.has_key?(:minimum) || params.has_key?(:maximum)
        @minimum_budget, @maximum_budget = form_rate_range_values(params[:minimum],params[:maximum])
        params[:filter][:price_gteq], params[:filter][:price_lteq]  = @minimum_budget, @maximum_budget
        buget_text = "for " + [@minimum_budget, @maximum_budget].join(" - ") unless @minimum_budget.nil? && @maximum_budget.nil?
      end
      unless params[:location].blank?
        loc_text = "in " + params[:location]
        params[:filter][:location_eq] = params[:location]
        loc_based_project = Project.near(params[:location], params[:miles])
      end
      unless params[:skills].blank?
        skill_text = params[:skills]
        params[:filter][:skills_cont] = params[:skills]
      end
      params[:filter][:user_id_present] = "1"
      if dr_projects.blank?
        search_pro = Project.ransack(params[:filter]).result
      else
        search_pro = Project.where("id NOT IN (#{dr_projects.join(",")})").ransack(params[:filter]).result
      end
      filter_projects = loc_based_project.blank? ? search_pro.order("created_at DESC") : (loc_based_project + search_pro).uniq.sort_by(&:created_at).reverse
      @projects = !filter_projects.nil? ? filter_projects : Array.new
      @loc_text = [loc_text]
      @search_text = [client_text,description_text,check_filter_text,buget_text,skill_text]
    elsif params.has_key?(:search_name) && !params[:search_name].empty?
      params[:filter] = {}
      params[:filter][:title_cont] = params[:search_name]
      params[:filter][:user_id_present] = "1"
      if dr_projects.blank?
        @projects = Project.ransack(params[:filter]).result #.order("created_at DESC")
      else
        @projects = Project.where("id NOT IN (#{dr_projects.join(",")})").ransack(params[:filter]).result.order("created_at DESC")
      end
      @request = params[:search_name]
    else
      #filter_project = Array.new
      if dr_projects.blank?
        @projects = Project.where('created_at >= :ten_days_ago',:ten_days_ago  => Time.now - 10.days) #.order("created_at DESC")
      else
        @open = Project.where('created_at >= :ten_days_ago',:ten_days_ago  => Time.now - 10.days)
        @projects = @open.where("id NOT IN (#{dr_projects.join(",")})")#.order("created_at DESC")
        #@projects = Kaminari.paginate_array(@projects.order(sort_column + ' ' + sort_direction)).per_page_kaminari(params[:page]).per(1)
      end

      #@projects.each {|p| filter_project.push(p) if p.pro_client }
      #@projects.each {|p| filter_project.push(p) if !p.pro_client }

    end
    complete = []
    @projects = @projects.where("user_id IS NOT NULL")
    @projects.each {|proj| complete << proj.id if proj.proposal_due_days < 0 }
    unless loc_based_project.blank?
      @projects = @projects.reject {|p| complete.include?(p.id) } unless complete.blank?
    else
      @projects = @projects.where("id NOT IN (#{complete.join(",")})") unless complete.blank?
      if params[:sort] == "time_left"
        @projects = @projects.sort {|a, b| a.updated_proposal_due_days <=> b.updated_proposal_due_days }
        @projects = @projects.reverse if params[:direction] == "desc"
      else
        @projects = @projects.order(sort_column + ' ' + sort_direction)
      end
    end
    @projects = Kaminari.paginate_array(@projects).per_page_kaminari(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => Project.custom_json(@projects, current_user, false, false, true) }
    end
  end

  def show
    search(Project, "projects")
    if params[:id].to_i > 0 #to_i will return 0 if the id is a string
      @project = Project.find(params[:id])
    else
      @project = Project.find_by_url_name(params[:id])
    end
    @page_title = @project.title+" on filmmo"
    @comment = Comment.new
    @producer = @project.user
    @real_videos = @project.videos.real
    # FIXME
    @sorted_roles = Hash.new

    @project.roles.each do |role|
      if @sorted_roles.has_key?(role.name) then
        @sorted_roles[role.name][:role_list] << role
      else
        @sorted_roles[role.name] = {:role_list => [role], :open_count => 0, :filled_count => 0, :total_count => 0}
      end

      @sorted_roles[role.name][:total_count] += 1

      if role.filled
        @sorted_roles[role.name][:filled_count] += 1
      else
        @sorted_roles[role.name][:open_count] += 1
      end
    end
  end

  def edit
    search(Project, "projects")
    project_fields
    3.times do |index|
      @project.photos[index] || @project.photos.build
    end
    @videos = @project.videos
    @videos.present? || @videos.build
  end

  def new
    search(Project, "projects")
    project_fields
    @project.user = current_user
    @project.roles.build
    3.times do
      @project.photos.build
      @video = @project.videos.build
    end
  end

  def create

    @project.user_id = current_user.id
    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, :notice => 'Project was successfully created.' }
        format.json { render :json => {
                        :success => true,
                        :notice => 'Project info was saved'
                      } }
      else
        format.html { render :action => "new" }
        format.json { render :json => {
                        :success => true,
                        :notice => 'Project info was saved'
                      } }
      end
    end
  end

  def update

    respond_to do |format|
      if @project.update_attributes(params[:project])
        format.html { redirect_to @project, :notice => @project.title + ' Project was successfully updated.' }
        format.json { render :json => {
                      :success => true,
                      :notice => 'Project info was saved'
                    } }
      else
        format.html { render :action => "edit", :notice => 'Project was not created.' }
        format.json { render :json => {
                      :success => true,
                      :notice => 'Project info was saved'
                    } }
      end
    end
  end

  def destroy
    @project.destroy
    respond_to do |format|
     format.html { redirect_to admin_admin_projects_url, :notice => @project.title + ' Project was deleted.' }
    end
  end

  def step_1
    if params[:project_id].present?
      # editing
      @project = Project.find(params[:project_id])
      if @project.update_attributes(params[:project])

        DeleteActivities.new( @project ).del_1_day_ago_updates

        @project.create_activity :update, owner: current_user

        render 'projects/step_2_form', :layout => false
      else
        render :json => false
      end
    else
      # new project
      if @project = Project.create(params[:project])
        @project.user = current_user
        @project.save
        @project.create_activity :create, owner: current_user
        render 'projects/step_2_form', :layout => false
      else

        render :json => false
      end
    end
  end

  def step_2
    @project = Project.find(params[:project_id])
    if @project.update_attributes(params[:project])
      render 'projects/step_3_form', :layout => false
    else
      render :json => false
    end
  end


  def add_filled_role
    project = Project.find(params[:project_id])

    if params[:role][:id].present?

      role = Role.find(params[:role][:id])

      # making the subroles nil and cast just in case if it as subroles before and when edited the new data doesn't have a subrole.
      role.reset_optional_fields

      params[:role].delete(:id)

      role.update_attributes(params[:role])
    else
      role = project.roles.create(params[:role])
      # role.applications.create(:user_id => params[:role_user_id], :approved => true)
      # role.update_attributes(:filled => true)
    end
    render :json => role.to_json(:include => [{:applications => { :include => :user}}])
  end



  def files_upload

    if params['project']['photos_attributes'].present?
      attributes = params['project']['photos_attributes']

      # get the index of the parameters with image attribute present
      indexes_with_image = attributes.map do |index, attribute|
        if attribute.include?('image')
          index
        end
      end

      indexes_with_image.delete(nil)

      # only one image is submitted once anyway.
      index = indexes_with_image.first

      if index.present?
        # if id is present, that is a photo object that is already existing and being updated.
        if params['project']['photos_attributes'][index]['id'].present?
          photo_object = Photo.find(params['project']['photos_attributes'][index]['id'].to_i)
        else
          # id won't be present for those photos that are dynamically added by Numerous.js
          photo_object = Photo.new
        end

        photo_object.update_attributes(:image => params['project']['photos_attributes'][index]['image'])

        if  Rails.env == 'development'
          url = "http://" + request.env["HTTP_HOST"] + photo_object.image.url
        else
          url = photo_object.image.url
        end

        file_url = {
          :url => url,
          :id => photo_object.reload.id,
          :original_width => photo_object.reload.original_width,
          :original_height => photo_object.reload.original_height
        }

      end

    end
    render :json => file_url.to_json()
  end

  def project_fields
    @talents      = Project.role_types
    @genres       = Project.genres
    @is_type      = Project.types
    @unions       = Project.unions
    @status       = Project.status_stages
    @compensation = Project.compensation_stages
  end

  def view_project
      @project = Project.find(url_decode(params[:project_id]))
      @project_details = @project.project_details_list
      @client_details = @project.client_details
      @proposal = @project.project_proposals.build
      if current_filmmaker
        @myproposal = ProjectProposal.where("filmmaker_id =? AND project_id =?",current_filmmaker.id, @project.id).first
  	  end
  end

  def download_additional_docs
    project = Project.where("id = ?",params[:project_id]).first
    if project && !(project.project_attachments.blank?)
      file_name = project.title + "_" + "attachments.zip"
      t = Tempfile.new("my-temp-filename-#{Time.now}")
      Zip::ZipOutputStream.open(t.path) do |z|
        project.project_attachments.each do |pro_attachment|
          attachment = pro_attachment.attachment
          title = attachment.url.split("/")[5]
          z.put_next_entry(title)
          z.print IO.read(attachment.path)
        end
      end
      send_file t.path, :type => 'application/zip', :disposition => 'attachment', :filename => file_name
      t.close
    else
      redirect_to root_path
    end
  end

  def modify_project_proposal
     project_proposal = ProjectProposal.find(params[:project_proposal_id])
     if project_proposal.present?
       #conversation = Conversation.find(project_proposal.conversation_id)
       _current_user = current_client || current_filmmaker
       revison = project_proposal.create_proposal_revisions _current_user, params[:description]
       if revison.present?
         revison.create_modified_proposal_milestones	params[:milestones]
       end
       content = render_to_string( layout: false, partial: "/filmmakers/proposal_content", locals: { project_proposal: project_proposal })
       #current_client.reply_to_conversation(conversation, content)
     end
     redirect_to :back, notice: "Proposal has been modified!"
  end


  def form_rate_range_values(minimum,maximum)
    if !(minimum.blank?) && !(maximum.blank?)
      values = [minimum,maximum]
    else
      if !(minimum.blank?) && maximum.blank?
        values = [minimum,15000]
      end
      if minimum.blank? && !(maximum.blank?)
        values = [500,maximum]
      end
    end
    values
  end

  private
  def sort_column
    Project.column_names.include?(params[:sort]) ? params[:sort] : ((params[:sort] == "time_left") ? "time_left" : "created_at")
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : "desc"
  end


end

class ApplicationController < ActionController::Base
  #News Feed
  include PublicActivity::StoreController
  include RedirectHelper

  protect_from_forgery

  before_filter :subdomain_view_path

  # helper_method :current_user
  # hide_action :current_user
  helper_method :notification
  helper_method :activities
  helper_method :pro_user
  # Security & Authentication
  helper_method :user_signed_in?
  helper_method :correct_user?
  # Search
  helper_method :search
  helper_method :url_encode, :url_decode
  #helper_method :outh_user_type
  #before_filter :outh_user_type

  def outh_user_type
    #@outh_type = ""
    puts request.referer
  end

  # If the user authorization fails, a CanCan::AccessDenied exception will be raised.
  rescue_from CanCan::AccessDenied do |exception|
    if request.xhr?
      render :text => false
    else
      redirect_to root_url, notice: 'You are not authorized to access the page.'
    end
  end

  def require_user
     redirect_to root_url if current_client.nil? && current_filmmaker.nil?
   end

    def after_sign_in_path_for(resource)
    if resource.is_a?(Client)
      return clients_dashboard_url
    elsif resource.is_a?(AdminUser)
      return admin_dashboard_url
    else
      if resource.is_a?(Filmmaker)
       return filmmakers_dashboard_url
      end
    end
  end

  def main_search
    query = params[:q]

    events   = Event.search_events(query).limit(10)
    projects = Project.includes(:photos).search_projects(query).limit(10)
    users    = User.includes(:profile).search_users(query).limit(10)

    render :json => JSON.parse(users.to_json(:for_search => true)) + JSON.parse(projects.to_json(:for_search => true)) + JSON.parse(events.to_json(:for_search => true))
  end

  def check_url_param


    entity = params[:entity]
    params[:value] = view_context.truncate(params[:value], :length => 20, :separator => ' ', :omission => '')

    name = params[:value].gsub(/\s/,'-').gsub(/[^a-zA-Z0-9-]/, '').downcase

    id_check = false


    id_check = true if params[:entity_id].present?

    if id_check
      same_named_count = entity.camelize.constantize.where("lower(url_name) like lower(?) AND id <> ? ", "#{name}%", params[:entity_id]).count
    else
      same_named_count = entity.camelize.constantize.where("lower(url_name) like lower(?)", "#{name}%").count
    end

    if same_named_count > 0
      if id_check
        to_return = name + "-#{params[:entity_id]}"
      else
        # if the entity doesn't have an id, it will probably have id of last + 1
        total_entities =  entity.camelize.constantize.count > 0 ? entity.camelize.constantize.last.id : 0
        to_return = name + "-#{total_entities.to_i + 1 }"
      end
    else
      to_return = name
    end

    render :json => to_return.to_json()
  end


   def current_user
     @current_user = current_resource_client || current_resource_filmmaker
   end

   def pro_user
     return false if current_client.nil? && current_filmmaker.nil?
     if current_client
       current_client.pro_account ? true : false
     end

     if current_filmmaker
       current_filmmaker.pro_account ? true : false
     end
   end
  # helper_method :current_user


  def subdomain_view_path
    prepend_view_path "app/views/#{request.subdomain}_subdomain" if request.subdomain.present?
  end

  # Search for Home Directory
  def search(model=User, instance="users")
    begin
      @search = model.search(params[:q])
      instance_variable_set("@#{instance}", @search.result)
    rescue Exception => e
      Rails.logger.info "Exception in search: #{e.inspect}"
    end
    if params[:q]
      redirect_to(:controller => :users, :action => :index, :q => params[:q]) and return
    end
  end

  # Project Comments System

  def require_login
    redirect_to login_url, alert: "You must first log in or sign up." if current_user.nil?
  end


  def activities
    if @current_user
      activities = PublicActivity::Activity.order("created_at desc").where(owner_id: current_user.friend_ids, owner_type: "User")
    end
  end

  #Notification System
  def notification
    if @current_user
      notification = @current_user.receipts.is_unread.count
      notification if notification > 0
    end
  end

  def user_signed_in?
      return true if current_user
  end

  def correct_user?
    @user = User.find(params[:id])
    unless current_user == @user || @current_user.admin == true
      redirect_to root_url, :error => 'Access denied.'
    end
  end

  def admin_user?
    return true if current_user.admin=true
  end

  # def authenticate_user!
  #   if !current_user
  #     redirect_to new_user_url, :error => 'You need to sign in for access to this page.'
  #   end
  # end

  def report
    entity_class = params[:entity].camelize.constantize
    entity = entity_class.find(params[:id])
    message = params[:reason]
    user = current_filmmaker.blank? ? current_client.blank? ? nil : current_client : current_filmmaker
    UserMailer.delay.report_entity_mail(user, entity, message)
    render :text => true
  end

  def clear_temp_photo_objects
    Photo.where(:imageable_type => nil).destroy_all
  end


  def current_user
    user = super
    if params[:public_view].present? and params[:public_view] == "true"
      nil
    else
      user
    end
  end

	def search_location
	 	#ActiveRecord::Base.include_root_in_json = false
		locations = Geocoder.search(params[:term])
		full_addresses = normalize_locations locations
		#full_addresses.include_root_in_json = false
		render :json => full_addresses.to_json
	end

  def url_encode(param_id)
    Base64.urlsafe_encode64(param_id.to_s)
  end

  def url_decode(param_id)
    Base64.urlsafe_decode64(param_id).to_i
  end


private

	def normalize_locations locations
		result = []
		location_types = ['country', 'locality']
		return result if locations.empty?
		locations.each do |location|
		  p "=============================="
		  p location.address_components.first
		  p "=============================="
		 location_kind = location.address_components.first['types'].first
		  if location_kind.in? location_types
		    result << location.address_components.first['long_name']
		  end
		end
		#locations.each{|address| p address.data; p '====' }#result << address.data['formatted_address'] }
		result.uniq
	end

end

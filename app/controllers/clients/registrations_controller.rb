class Clients::RegistrationsController < Devise::RegistrationsController

  # load_and_authorize_resource :except => [:new]
 
  def new
      
      
      @client = Client.new
      @client.save
 #     @user.add_meta :user_client
   end
  
  def create
      
    build_resource(params[:client])

    if resource.save
				# create registered filmmaker a marketplace customer
	
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        redirect_back_or(edit_user_path(resource))
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  def after_sign_up_path_for(resource)
    
    '/clients/dashboard'
  end

end


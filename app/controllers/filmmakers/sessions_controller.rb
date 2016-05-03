class Filmmakers::SessionsController < Devise::SessionsController

  def new
   Rails.cache.write("oauth_user_type", "Filmmaker")
   Rails.cache.write("action_type","sign_in")
  end

  def resource_name
    :filmmaker
  end

  def resource_class
    "Filmmaker".constantize
  end
 
  def resource
    # Needs some remodelling not sure why had error with original 3rd June RR
    # @resource ||= Filmmaker.new
    @resource = @filmmaker 
  end
 
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:filmmaker]
  end
  
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    if @filmmaker.name == nil || @filmmaker.email == nil
      redirect_to edit_user_path(@filmmaker)
    else
      redirect_back_or(after_sign_in_path_for(@filmmaker))
    end
  end

end



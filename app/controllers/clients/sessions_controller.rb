class Clients::SessionsController < Devise::SessionsController

  # def new
  #   redirect_to root_url, notice: notice
  # end

  def resource_name
    :client
  end

  def resource_class
    "Client".constantize
  end
 
  def resource
    @resource ||= Client.new
    # @resource = @client
  end
 
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:client]
  end
  
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    if @client.profile == nil || @client.location == nil || @client.location == ""
      redirect_to edit_client_path(@client)
    else
      redirect_back_or(after_sign_in_path_for(@client))
    end
  end

end


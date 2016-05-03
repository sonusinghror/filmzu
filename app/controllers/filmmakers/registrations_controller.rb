class Filmmakers::RegistrationsController < Devise::RegistrationsController

  # load_and_authorize_resource :except => [:new]
  #  before_filter :outh_user_type
  def new
      @filmmaker = Filmmaker.new
        @outh_type = "Filmmaker"
        Rails.cache.write("oauth_user_type", "Filmmaker")
        Rails.cache.write("action_type", "sign_up")
      #@filmmaker.save
      # @user = User.new
      # @user.save
   end

  def create
    build_resource(params[:filmmaker])

    if resource.save
         # create registered filmmaker a marketplace customer
         BalancedJob.new.async.create_marketplace_customer(resource)

      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        redirect_back_or(filmmakers_portfolio(resource))

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

  def filmmakers_portfolio(resource)
   '/filmmakers/portfolio'
  end

  def after_sign_up_path_for(resource)
    '/filmmakers/portfolio'
  end

end

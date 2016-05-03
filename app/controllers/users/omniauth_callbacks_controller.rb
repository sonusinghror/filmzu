class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    facebook_data = request.env["omniauth.auth"]["extra"]["raw_info"]
    if request.env["omniauth.params"]["social_user"] == 'filmmaker'
      if request.env["omniauth.params"]["social_action"] == 'signin'
        filmmaker = Filmmaker.find_by_email(facebook_data["email"])
        if filmmaker.present?
          sign_in(:filmmaker, filmmaker)
          redirect_to "/filmmakers/dashboard"
        else
          redirect_to "/filmmakers/sign_up", notice: 'Please signup with facebook account first'
        end
      else
        filmmaker = Filmmaker.find_by_email(facebook_data["email"])
        if filmmaker.present?
          if filmmaker.provider == 'facebook'
            sign_in(:filmmaker, filmmaker)
            redirect_to "/filmmakers/dashboard"
          else
            redirect_to '/filmmakers/sign_up', notice: "An account with this email already exists"
          end
        else
          filmmaker_hash = {
            name: facebook_data['name'],
            email: facebook_data['email'],
            password: "login12*",
            is_company: 0,
            provider: "#{request.env['omniauth.auth']['provider'] rescue nil}",
            uid: "#{request.env['omniauth.auth']['uid'] rescue nil}",
            location: "#{request.env['omniauth.auth']['info']['location'] rescue nil}",
            oauth_token: "#{request.env['omniauth.auth']['credentials']['token'] rescue nil}",
            oauth_expires_at: "#{request.env['omniauth.auth']['credentials']['expires_at'] rescue nil}",
            fb_token: "#{request.env['omniauth.auth']['credentials']['token'] rescue nil}",
          }
          filmmaker = Filmmaker.new(filmmaker_hash)
          if filmmaker.save
            # call background job - create balanced customer
            BalancedJob.new.async.create_marketplace_customer(filmmaker)
            sign_in(:filmmaker, filmmaker)
            redirect_to "/filmmakers/portfolio"
          else
            flash[:error] = "#{filmmaker.errors.full_messages.join(', ') rescue nil}"
            redirect_to "/filmmakers/sign_up"
          end
        end
      end
    else
      if request.env["omniauth.params"]["social_action"] == 'signin'
        client = Client.find_by_email(facebook_data["email"])
        if client.present?
          sign_in(:client, client)
          redirect_to "/clients/dashboard"
        else
          redirect_to "/clients/sign_up", notice: 'Please signup with facebook account first'
        end
      else
        client = Client.find_by_email(facebook_data["email"])
        if client.present?
          if client.provider == 'facebook'
            sign_in(:client, client)
            redirect_to "/clients/dashboard"
          else
            redirect_to '/clients/sign_up', notice: "An account with this email already exists"
          end
        else
          client_hash = {
            name: facebook_data['name'],
            email: facebook_data['email'],
            password: "login12*",
            provider: "#{request.env['omniauth.auth']['provider'] rescue nil}",
            uid: "#{request.env['omniauth.auth']['uid'] rescue nil}",
            location: "#{request.env['omniauth.auth']['info']['location'] rescue nil}",
            oauth_token: "#{request.env['omniauth.auth']['credentials']['token'] rescue nil}",
            oauth_expires_at: "#{request.env['omniauth.auth']['credentials']['expires_at'] rescue nil}",
            fb_token: "#{request.env['omniauth.auth']['credentials']['token'] rescue nil}",
          }
          client = Client.new(client_hash)
          if client.save
            # call background job - create balanced customer
            BalancedJob.new.async.create_marketplace_customer(client)
            sign_in(:client, client)
            redirect_to "/clients/dashboard"
          else
            p client.errors.inspect
            flash[:error] = "#{client.errors.full_messages.join(', ')}"
            redirect_to "/clients/sign_up"
          end
        end
      end
    end
  end

  def linkedin
    linkedin_data = request.env["omniauth.auth"]["info"]
    if request.env["omniauth.params"]["social_user"] == 'filmmaker'
      if request.env["omniauth.params"]["social_action"] == 'signin'
        filmmaker = Filmmaker.find_by_email(linkedin_data["email"])
        if filmmaker.present?
          sign_in(:filmmaker, filmmaker)
          redirect_to "/filmmakers/dashboard"
        else
          redirect_to "/filmmakers/sign_up", notice: 'Please signup with linkedin account first'
        end
      else
        filmmaker = Filmmaker.find_by_email(linkedin_data["email"])
        if filmmaker.present?
          if filmmaker.provider == 'linkedin'
            sign_in(:filmmaker, filmmaker)
            redirect_to "/filmmakers/dashboard"
          else
            redirect_to '/filmmakers/sign_up', error: "An account with this email already exists"
          end
        else
          filmmaker_hash = {
            name: linkedin_data["name"],
            email: linkedin_data["email"],
            password: "login12*",
            provider: "#{request.env['omniauth.auth']['provider'] rescue nil}",
            uid: "#{request.env['omniauth.auth']['uid'] rescue nil}",
            oauth_token: "#{request.env['omniauth.auth']['credentials']['token'] rescue nil}",
            oauth_expires_at: "#{request.env['omniauth.auth']['credentials']['expires_at'] rescue nil}"
          }
          filmmaker = Filmmaker.new(filmmaker_hash)
          if filmmaker.save
            # call background job - create balanced customer
            BalancedJob.new.async.create_marketplace_customer(filmmaker)
            sign_in(:filmmaker, filmmaker)
            redirect_to "/filmmakers/portfolio"
          else
            flash[:error] = "#{filmmaker.errors.full_messages.join(', ') rescue nil}"
            redirect_to "/filmmakers/sign_up"
          end
        end
      end
    else
      if request.env["omniauth.params"]["social_action"] == 'signin'
        client = Client.find_by_email(linkedin_data["email"])
        if client.present?
          sign_in(:client, client)
          redirect_to "/clients/dashboard"
        else
          redirect_to "/clients/sign_up", notice: 'Please signup with linkedin account first'
        end
      else
        client = Client.find_by_email(linkedin_data['email'])
        if client.present?
          if client.provider == 'linkedin'
            sign_in(:client, client)
            redirect_to "/clients/dashboard"
          else
            redirect_to '/clients/sign_up', error: "An account with this email already exists"
          end
        else
          client_hash = {
            name: linkedin_data["name"],
            email: linkedin_data["email"],
            password: "login12*",
            provider: "#{request.env['omniauth.auth']['provider'] rescue nil}",
            uid: "#{request.env['omniauth.auth']['uid'] rescue nil}",
            oauth_token: "#{request.env['omniauth.auth']['credentials']['token'] rescue nil}",
            oauth_expires_at: "#{request.env['omniauth.auth']['credentials']['expires_at'] rescue nil}"
          }
          client = Client.new(client_hash)
          if client.save
            # call background job - create balanced customer
            BalancedJob.new.async.create_marketplace_customer(client)
            sign_in(:client, client)
            redirect_to "/clients/dashboard"
          else
            flash[:error] = "#{client.errors.full_messages.join(', ') rescue nil}"
            redirect_to "/clients/sign_up"
          end
        end
      end
    end
  end

  def failure
    begin
      if params.present? && params.is_a?(Hash) && params[:oauth_problem].present?
        if params[:oauth_problem] == 'user_refused'
          flash[:error] = "You have canceled the social signup/login"
        else
          flash[:error] = "Please try again"
        end
        url = root_url
        if params[:social_user] == 'filmmaker'
          url = new_filmmaker_registration_url if params[:social_action] == 'signup'
          url = new_filmmaker_session_url if params[:social_action] == 'signin'
        end
        if params[:social_user] == 'client'
          url = new_client_registration_url if params[:social_action] == 'signup'
          url = new_client_session_url if params[:social_action] == 'signin'
        end
        redirect_to url
      else
        super
      end
    rescue
      super
    end
  end
end

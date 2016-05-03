class ClientMailer < ActionMailer::Base
  default from: "\"Filmzu Notifications\" <notifications@filmzu.com>"
  
  def signup_confirmation(client)
    @client = client
    mail to: client.email, subject: "Sign Up Confirmation"
    @url  = 'http://filmzu.com/sign_in'
    #  @client = client
    # attachments["filmzu1.png"] = File.read("#{Rails.root}/assets/images/filmzu1.png")
    # mail(:to => "#{client.name} <#{client.email}>", :subject => "Registered")
  end


  def proposal_received(client, project)
    @project = Project.find(project)
    @client = client
    mail to: client.email, subject: "Proposal Received"
  end
  
  def welcome_email(client)
     @url  = 'http://filmzu.com/sign_in'
     recipients client.email
     from "<notifications@filmzu.com>"                                           
     subject "Welcome to Filmzu"          
     content_type "text/html" # use some_other_template.text.(html|plain).erb instead template "some_other_template"
  end

end

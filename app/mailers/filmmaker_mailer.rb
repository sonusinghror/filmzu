class FilmmakerMailer < ActionMailer::Base
  default from: "\"Filmzu Notifications\" <notifications@filmzu.com>"
  
  def signup_confirmation(filmmaker)
    @filmmaker = filmmaker
    mail to: filmmaker.email, subject: "Sign Up Confirmation"
  end

  def proposal_submitted_confirmation(filmmaker, project)
    @project = Project.find(project)
    @filmmaker = filmmaker
    mail(:to => filmmaker.email, :subject => "Proposal Sent",  :bcc => ["rupe@filmzu.com", "nick@filmzu.com"])
  end

  def welcome_email(filmmaker) 
     recipients user.email 
     from "<notifications@filmzu.com>" 
     subject "Welcome to Filmzu"  
     content_type "text/html" # use some_other_template.text.(html|plain).erb instead template "some_other_template"
  end
end

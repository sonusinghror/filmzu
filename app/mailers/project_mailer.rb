class ProjectMailer < ActionMailer::Base
  default from: "\"Filmzu Notifications\" <notifications@filmzu.com>"

  def project_confirmation(project)
    @client = project.client
    @project = project
    mail(:to => project.client.email, :subject => "Your Project is Live",  :bcc => ["rupe@filmzu.com", "nick@filmzu.com"])
  end
end
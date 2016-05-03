class ProjectFeedback < ActiveRecord::Base
  attr_accessible :client_id, :cost, :expertise, :filmmaker_id, :professional, :project_id, :response, :schedule, :comment, :total_rating
  belongs_to :project
  belongs_to :client
  belongs_to :filmmaker

  def self.set_filmmaker_feedback(param)
    project = Project.find_by_id(param[:feedback][:project_id])
    total_rating = param[:feedback].values_at(:cost,:response,:expertise,:schedule,:professional).collect{|i| i.to_i}.sum
    param[:feedback].merge!(:client_id => project.client.id, :total_rating => total_rating)
    feedback_available = self.where(:client_id => project.client.id, :filmmaker_id => param[:feedback][:filmmaker_id], :project_id => param[:feedback][:project_id]).first
    feedback_available.nil? ? self.create(param[:feedback]) : feedback_available.update_attributes(param[:feedback])
  end
  
  def self.filmamker_feedback_projects(client)
    client.project_feedbacks.includes(:project)
  end
  
  def average_rating
      average = cost + response + expertise + schedule + professional
      average.zero? ? 0 : average/5
  end
end

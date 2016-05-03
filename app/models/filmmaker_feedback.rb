class FilmmakerFeedback < ActiveRecord::Base
  attr_accessible :attribute_key, :attribute_value, :comment, :rating, :filmmaker_id, :project_id
	belongs_to :project
	belongs_to :filmmaker
	belongs_to :client

  FILMMAKER_FEEDBACK_ATTRIBUTES = ['Quality Of Work', 'Attitude', 'Responsiveness', 'Experience', 'On Budget', 'On Time', 'Comment']
  CLIENT_FEEDBACK_ATTRIBUTES = ['Cost', 'Response', 'Expertise', 'Schedule', 'Professional']
end

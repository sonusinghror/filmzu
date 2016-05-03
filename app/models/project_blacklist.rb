class ProjectBlacklist < ActiveRecord::Base
  # attr_accessible :title, :body
	attr_accessible :filmmaker_id, :blocked_at	
	belongs_to :project
	belongs_to :filmmaker
end

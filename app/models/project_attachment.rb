class ProjectAttachment < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :attachment
	belongs_to :project
	mount_uploader :attachment, AttachmentUploader
end

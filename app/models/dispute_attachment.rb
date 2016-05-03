class DisputeAttachment < ActiveRecord::Base
  attr_accessible :attachment
  belongs_to :dispute
  mount_uploader :attachment, AttachmentUploader
end
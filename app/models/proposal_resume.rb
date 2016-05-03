class ProposalResume < ActiveRecord::Base
  attr_accessible :attachment
  belongs_to :project_proposal
  mount_uploader :attachment, AttachmentUploader
end
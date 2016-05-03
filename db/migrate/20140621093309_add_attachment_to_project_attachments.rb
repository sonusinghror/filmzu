class AddAttachmentToProjectAttachments < ActiveRecord::Migration
  def change
    add_column :project_attachments, :attachment, :string
  end
end

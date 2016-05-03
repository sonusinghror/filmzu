class CreateProjectAttachments < ActiveRecord::Migration
  def change
    create_table :project_attachments do |t|
			t.references :project
      t.timestamps
    end
  end
end

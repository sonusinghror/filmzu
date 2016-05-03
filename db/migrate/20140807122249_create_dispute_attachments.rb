class CreateDisputeAttachments < ActiveRecord::Migration
  def change
    create_table :dispute_attachments do |t|
      t.string :attachment
      t.references :dispute
      t.timestamps
    end
  end
end

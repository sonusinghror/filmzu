class CreateDirectHireProposals < ActiveRecord::Migration
  def change
    create_table :direct_hire_proposals do |t|
      t.text :cover_letter
      t.date :desired_start_date
      t.date :desired_end_date
      t.boolean :is_declined
      t.boolean :is_approved
      t.references :filmmaker
      t.references :client
      t.timestamps
    end
  end
end

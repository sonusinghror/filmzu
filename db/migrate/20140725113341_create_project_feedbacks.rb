class CreateProjectFeedbacks < ActiveRecord::Migration
  def change
    create_table :project_feedbacks do |t|
      t.integer :client_id
      t.integer :filmmaker_id
      t.integer :project_id
      t.integer :cost
      t.integer :response
      t.integer :expertise
      t.integer :schedule
      t.integer :professional

      t.timestamps
    end
  end
end

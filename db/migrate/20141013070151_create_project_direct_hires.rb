class CreateProjectDirectHires < ActiveRecord::Migration
  def change
    create_table :project_direct_hires do |t|
      t.integer :filmmaker_id
      t.integer :client_id
      t.integer :direct_hire_proposal_id
      t.timestamps
    end
  end
end

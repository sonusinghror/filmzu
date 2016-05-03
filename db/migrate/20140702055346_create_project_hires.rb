class CreateProjectHires < ActiveRecord::Migration
  def change
    create_table :project_hires do |t|
      t.references :filmmaker
      t.references :client
      t.references :proposal
      t.timestamps
    end
  end
end

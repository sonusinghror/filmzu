class CreateDirectHires < ActiveRecord::Migration
  def change
    create_table :direct_hires do |t|
      t.references :filmmaker
      t.references :client
      t.references :direct_hire_proposal
      t.timestamps
    end
  end
end

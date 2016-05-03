class CreateProjectBlacklists < ActiveRecord::Migration
  def change
    create_table :project_blacklists do |t|
			t.references :project
			t.references :filmmaker
			t.datetime :blocked_at
      t.timestamps
    end
  end
end

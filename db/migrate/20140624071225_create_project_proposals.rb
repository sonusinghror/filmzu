class CreateProjectProposals < ActiveRecord::Migration
  def change
    create_table :project_proposals do |t|
      t.text 			:cover_letter
      t.date 			:desired_start_date
      t.date 			:desired_end_date
			t.integer		 :proposable_id
      t.string  		:proposable_type
      t.timestamps
    end
  end
end

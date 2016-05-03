class CreateFilmmakerFeedbacks < ActiveRecord::Migration
  def change
    create_table :filmmaker_feedbacks do |t|
      t.string :attribute_key
      t.string :attribute_value
      t.integer :rating
      t.text :comment
			t.references :filmmaker
			t.references :project
			t.references :client
      t.timestamps
    end
  end
end

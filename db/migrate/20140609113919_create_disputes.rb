class CreateDisputes < ActiveRecord::Migration
  def change
    create_table :disputes do |t|
      t.integer :dispute_id
      t.string :dispute_description
      t.date :dispute_date

      t.timestamps
    end
  end
end

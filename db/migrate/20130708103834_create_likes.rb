class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
  		t.references :user
  		t.references :loveable, polymorphic: true
      t.timestamps
    end
  end
end

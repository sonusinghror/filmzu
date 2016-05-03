class CreateUrls < ActiveRecord::Migration
  def change
    create_table :urls do |t|
      t.string :url
      t.references :urlable, :polymorphic => true
      t.timestamps
    end
  end
end

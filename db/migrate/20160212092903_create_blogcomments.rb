class CreateBlogcomments < ActiveRecord::Migration
  def change
    create_table :monologue_blogcomments do |t|
      t.text :comment
      t.integer :post_id
      t.timestamps
    end
  end
end

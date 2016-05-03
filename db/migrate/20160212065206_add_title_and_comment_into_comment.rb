class AddTitleAndCommentIntoComment < ActiveRecord::Migration
  def up
  	add_column :comments, :title, :string
  	add_column :comments, :comment, :text
  end

  def down
  	remove_column :comments, :title
  	remove_column :comments, :comment
  end
end

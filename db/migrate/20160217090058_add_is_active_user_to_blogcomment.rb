class AddIsActiveUserToBlogcomment < ActiveRecord::Migration
  def change
  	add_column :monologue_blogcomments, :is_active, :boolean, :default => false
  	add_column :monologue_blogcomments, :user_name, :string
  	add_column :monologue_blogcomments, :user_email, :string
  end
end

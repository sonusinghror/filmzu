class AddImageToBlogPost < ActiveRecord::Migration
  def change
    add_column :monologue_posts, :image, :string
  end
end

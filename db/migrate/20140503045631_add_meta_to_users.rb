class AddMetaToUsers < ActiveRecord::Migration
  def change
    add_column :users, :meta_id, :integer
    add_column :users, :meta_type, :string
  end
end

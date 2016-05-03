class ChangeDisputes < ActiveRecord::Migration
  def up
    add_column :disputes, :status, :string
  end

  def down
    remove_column :disputes, :status
  end
end

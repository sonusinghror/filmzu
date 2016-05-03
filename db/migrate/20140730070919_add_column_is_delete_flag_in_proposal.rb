class AddColumnIsDeleteFlagInProposal < ActiveRecord::Migration
  def up
    add_column :project_proposals, :is_delete, :boolean, :default => false
  end

  def down
    remove_column :project_proposals, :is_delete
  end
end

class AddIsModifiedColumnToProjectProposals < ActiveRecord::Migration
  def change
    add_column :project_proposals, :is_modified, :boolean, :default => false, :after => :is_delete
    add_column :direct_hire_proposals, :is_modified, :boolean, :default => false, :after => :is_approved
  end
end

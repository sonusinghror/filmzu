class AddConversationIdToProjectProposal < ActiveRecord::Migration
  def change
    add_column :project_proposals, :conversation_id, :integer, after: 'desired_end_date'
  end	
end

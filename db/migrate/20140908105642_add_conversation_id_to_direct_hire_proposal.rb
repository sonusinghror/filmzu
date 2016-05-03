class AddConversationIdToDirectHireProposal < ActiveRecord::Migration
  def change
    add_column :direct_hire_proposals, :conversation_id, :integer, after: 'filmmaker_id'
  end
end

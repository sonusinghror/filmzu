class ChangeDisputeIdColNameInDisputesTable < ActiveRecord::Migration
  def up
    rename_column :disputes, :dispute_id, :proposal_id
  end

  def down
    rename_column :disputes, :proposal_id, :dispute_id
  end
end

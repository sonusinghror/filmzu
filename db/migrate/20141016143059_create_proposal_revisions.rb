class CreateProposalRevisions < ActiveRecord::Migration
  def change
    create_table :proposal_revisions do |t|
      t.references :project_proposal
      t.integer :revised_by
      t.string :revised_user_type
      t.integer :revision_count
      t.text :description
      
      t.timestamps
    end
  end
end

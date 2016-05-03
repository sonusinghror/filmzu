class CreateProposalResumes < ActiveRecord::Migration
  def change
    create_table :proposal_resumes do |t|
      t.string :attachment
      t.references :project_proposal
      t.timestamps
    end
  end
end

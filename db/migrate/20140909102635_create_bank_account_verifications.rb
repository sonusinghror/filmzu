class CreateBankAccountVerifications < ActiveRecord::Migration
  def change
    create_table :bank_account_verifications do |t|
      t.integer :bank_account_id
      t.integer :attempts
      t.integer :attempts_remaining
      t.string :balanced_created_at
      t.string :deposit_status
      t.string :href
      t.string :balanced_id
      t.string :link_bank_account
      t.string :balanced_updated_at
      t.string :verification_status
      t.timestamps
    end
  end
end

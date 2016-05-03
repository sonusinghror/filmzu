class CreateBankAccounts < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.string :bank_account_uri
      t.string :bank_name
      t.references :bank_accountable, :polymorphic => true
      t.timestamps
    end
  end
end

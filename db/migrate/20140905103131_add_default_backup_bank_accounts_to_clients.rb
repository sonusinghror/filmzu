class AddDefaultBackupBankAccountsToClients < ActiveRecord::Migration
  def change
    add_column :clients, :default_bank_account, :integer
    add_column :clients, :default_backup_account, :integer
  end
end

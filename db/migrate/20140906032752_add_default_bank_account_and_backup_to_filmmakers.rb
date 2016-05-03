class AddDefaultBankAccountAndBackupToFilmmakers < ActiveRecord::Migration
  def change
  	add_column :filmmakers, :default_bank_account, :integer
    add_column :filmmakers, :default_backup_account, :integer
  end
end

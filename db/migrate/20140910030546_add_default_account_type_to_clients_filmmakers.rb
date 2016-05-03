class AddDefaultAccountTypeToClientsFilmmakers < ActiveRecord::Migration
  def change
    rename_column :clients, :default_bank_account, :default_account
    rename_column :filmmakers, :default_bank_account, :default_account
    add_column :clients, :default_account_type, :string
    add_column :clients, :default_backup_account_type, :string
    add_column :filmmakers, :default_account_type, :string
    add_column :filmmakers, :default_backup_account_type, :string
  end
end

class AddPaymentFieldsToAdminUsers < ActiveRecord::Migration
  def change
    add_column :admin_users, :balanced_uri, :string
    add_column :admin_users, :default_account, :integer
    add_column :admin_users, :default_backup_account, :integer
    add_column :admin_users, :default_account_type, :string
    add_column :admin_users, :default_backup_account_type, :string
  end
end

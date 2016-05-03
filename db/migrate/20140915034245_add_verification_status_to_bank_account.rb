class AddVerificationStatusToBankAccount < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :verification_status, :string
  end
end

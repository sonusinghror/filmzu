class CreateProAccounts < ActiveRecord::Migration
  def change
    create_table :pro_accounts do |t|
      t.string :account_type
      t.datetime :payment_at
			t.integer :accountable_id
      t.string  :accountable_type
      t.timestamps
    end
  end
end

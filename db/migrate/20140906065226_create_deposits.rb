class CreateDeposits < ActiveRecord::Migration
  def change
    create_table :deposits do |t|
      t.belongs_to :depositable, polymorphic: true
      t.decimal :amount, :precision => 8, :scale => 2
      t.text :appears_on_statement_as
      t.string :balanced_created_at
      t.string :currency
      t.text :description
      t.text :failure_reason
      t.string :failure_reason_code
      t.string :href
      t.string :balanced_id
      t.string :status
      t.string :transaction_number
      t.string :balanced_updated_at
      t.timestamps
    end
    add_index :deposits, [:depositable_id, :depositable_type]
    add_column :clients, :balance, :decimal, :precision => 8, :scale => 2, :default => 0
  end
end

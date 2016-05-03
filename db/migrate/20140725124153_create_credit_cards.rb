class CreateCreditCards < ActiveRecord::Migration
  def change
    create_table :credit_cards do |t|
      t.string :credit_card_uri
      t.boolean :is_authenticated
      t.string :card_type
      t.references :card_accountable, :polymorphic => true
      t.timestamps
    end
  end
end
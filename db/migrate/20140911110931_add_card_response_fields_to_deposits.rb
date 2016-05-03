class AddCardResponseFieldsToDeposits < ActiveRecord::Migration
  def change
    add_column :deposits, :link_card_hold, :string
    add_column :deposits, :link_customer, :string
    add_column :deposits, :link_dispute, :string
    add_column :deposits, :link_order, :string
    add_column :deposits, :link_source, :string
  end
end

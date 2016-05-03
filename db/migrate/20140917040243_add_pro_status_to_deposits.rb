class AddProStatusToDeposits < ActiveRecord::Migration
  def change
    add_column :deposits, :pro, :boolean, :default => false
  end
end
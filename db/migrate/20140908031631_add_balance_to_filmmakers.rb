class AddBalanceToFilmmakers < ActiveRecord::Migration
  def change
    add_column :filmmakers, :balance, :decimal, :precision => 8, :scale => 2, :default => 0
  end
end

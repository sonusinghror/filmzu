class AddPaymentColumns < ActiveRecord::Migration
  def up
    add_column :filmmakers, :balanced_uri, :string
    add_column :clients,    :balanced_uri, :string
  end

  def down
  end
end

class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.string :provider
      t.integer :uid
      t.integer :user_id
      t.integer :client_id
      t.integer :filmmaker_id
      t.string :confirmation_token
      t.string :name

      t.timestamps
    end
  end
end

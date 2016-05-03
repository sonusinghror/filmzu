class AddLinkedinTokenToFilmmakers < ActiveRecord::Migration
  def change
    add_column :filmmakers, :provider, :string
    add_column :filmmakers, :uid, :string
  end
end

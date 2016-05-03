class AddFieldsToFilmmakers < ActiveRecord::Migration
  def change
    add_column :filmmakers, :verified, :boolean
    add_column :filmmakers, :verified_by_admin, :boolean
  end
end

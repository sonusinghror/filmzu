class AddRoleToFilmmakers < ActiveRecord::Migration
  def change
    add_column :filmmakers, :role, :string
  end
end

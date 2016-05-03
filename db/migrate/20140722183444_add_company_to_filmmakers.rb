class AddCompanyToFilmmakers < ActiveRecord::Migration
  def up
    add_column :filmmakers, :is_company, :boolean, :default => false
    add_column :filmmakers, :company, :string
  end

  def down
    remove_column :filmmakers, :is_company, :boolean
    remove_column :filmmakers, :company, :string
  end
end

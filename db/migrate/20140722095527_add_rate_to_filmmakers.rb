class AddRateToFilmmakers < ActiveRecord::Migration
  def change
    add_column :filmmakers, :rate, :integer
  end
end

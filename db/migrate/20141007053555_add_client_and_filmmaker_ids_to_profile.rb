class AddClientAndFilmmakerIdsToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :filmmaker_id, :integer, :after => :user_id
    add_column :profiles, :client_id, :integer, :after => :filmmaker_id    
  end
end

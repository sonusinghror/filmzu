class AddTotalRatingToProjectFeedbacks < ActiveRecord::Migration
  def self.up
    add_column :project_feedbacks, :total_rating, :integer, :default => 0, :after => :professional
  end

  def self.down
    remove_column :project_feedbacks, :total_rating
  end 
end

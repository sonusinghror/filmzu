class CreateMilestones < ActiveRecord::Migration
  def change
    create_table :milestones do |t|
      t.string :title
      t.string :description
      t.date :startdate
      t.date :enddate

      t.timestamps
    end
  end
end

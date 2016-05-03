class Milestone < ActiveRecord::Base
  belongs_to :user
  belongs_to :client
  belongs_to :filmmaker 
  belongs_to :meta, polymorphic: true
  belongs_to :project
  attr_accessible :description, :enddate, :startdate, :title
end

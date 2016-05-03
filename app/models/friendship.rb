class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, class_name: "User"
  belongs_to :client, class_name: "User"
  belongs_to :filmmaker, class_name: "User"

  attr_accessible :friend_id
end

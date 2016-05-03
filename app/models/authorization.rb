class Authorization < ActiveRecord::Base

attr_accessible :client_id, :confirmation_token, :filmmaker_id, :name, :provider

belongs_to :client
belongs_to :filmmaker

 
end

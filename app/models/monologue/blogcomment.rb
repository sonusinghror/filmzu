module Monologue
	class Blogcomment < ActiveRecord::Base
	  attr_accessible :title, :comment, :user, :post, :user_name, :user_email
	  belongs_to :post
	end
end

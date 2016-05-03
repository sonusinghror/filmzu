class StaticPagesController < ApplicationController
  
	def our_story
		
	end
	
	def team
	  @page_title = 'Founders Rupert Ralston & Nick Ghirardelli of Filmzu'   
  end
  
  def about
    @page_title = 'What is the Filmzu Video Production Marketplace?'   
  end

end

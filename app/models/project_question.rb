class ProjectQuestion < ActiveRecord::Base
  attr_accessible :answer_text, :question_text
	belongs_to :project

	validates_presence_of :answer_text

  def self.select_options_list(i)
    case i
      when 0 then ['TV Commercial', 'Crowdfunding', 'Web Video', 'Explainer Video', 'Event', 'Other']
      when 1 then ['Live Action', 'Animated', 'Stop Motion', 'Motion Graphics', 'Whiteboard']
      when 2,3 then ['Yes', 'No', "I don't know"]
      when 4 then ['No', 'Original', 'Licensed', 'Stock']
      when 5 then ['30 sec', '1 min', '1-2 min', '2-5 min', '5+ min']
      when 6 then ['1 day', '3 days', '5 days', '7 days', '10 days']
      when 7 then ['Everyone', 'Filmzu Pro Only']
    end
  end
end

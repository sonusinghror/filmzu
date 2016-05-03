# require "omniauth-facebook"
  # OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
 # config.omniauth :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'], :scope => 'email, read_friendlists',
 #                 :strategy_class => OmniAuth::Strategies::Facebook, :display => "page", :image_size => "large"
 # require 'omniauth-linkedin'
#  config.omniauth :linkedin, "3783841", "1OF2gq4MB0fwObq1"

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '414172748642577', '0b2f7afa0c27ba5741c3ae636178420d'
  #provider :linkedin, ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET']
  provider :linkedin, '75j69o9xmww893', 'LO3NHi2TKkqMvvaV'
end

#Development credentials
=begin
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '117233151679001', '9ee06b4971bac749e750456a49fddbd3'
  provider :linkedin, '01u5z5rydvux', 'tqnkdsOTW5qwE2As'
end
=end

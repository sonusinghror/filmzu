# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project_feedback do
    client_id 1
    filmmaker_id 1
    project_id 1
    cost 1
    response 1
    expertise 1
    schedule 1
    professional 1
  end
end

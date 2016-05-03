# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project_proposal_milestone do
    name "MyString"
    delivery_date "2014-06-24"
    amount 1.5
  end
end

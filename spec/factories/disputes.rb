# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :dispute do
    dispute_id 1
    dispute_description "MyString"
    dispute_date "2014-06-09"
  end
end

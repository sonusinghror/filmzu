# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :filmmaker_feedback do
    attribute_key "MyString"
    attribute_value ""
    rating 1
    comment "MyText"
  end
end

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :milestone do
    title "MyString"
    description "MyString"
    startdate "2014-05-01"
    enddate "2014-05-01"
  end
end

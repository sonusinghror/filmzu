# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :direct_hire_proposal do
    cover_letter "MyText"
    desired_start_date "2014-07-28"
    desired_end_date "2014-07-28"
    is_declined false
    is_approved false
  end
end

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project_proposal do
    cover_letter "MyText"
    desired_start_date "2014-06-24"
    desired_end_date "2014-06-24"
  end
end

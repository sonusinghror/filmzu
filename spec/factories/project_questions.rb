# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :project_question do
    question_text "MyString"
    answer_text "MyString"
  end
end

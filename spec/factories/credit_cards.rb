# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :credit_card do
    credit_card_uri "MyString"
    is_authenticated false
    card_type "MyString"
  end
end

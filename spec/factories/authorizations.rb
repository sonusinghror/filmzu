# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :authorization do
    provider "MyString"
    client_id 1
    filmmaker_id 1
    confirmation_token "MyString"
    name "MyString"
  end
end

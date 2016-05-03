# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :account do
    account_id "MyString"
    credit_card "MyString"
    default_account "MyString"
    backup_payment "MyString"
  end
end

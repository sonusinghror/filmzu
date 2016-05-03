require 'spec_helper'

describe "accounts/edit" do
  before(:each) do
    @account = assign(:account, stub_model(Account,
      :account_id => "MyString",
      :credit_card => "MyString",
      :default_account => "MyString",
      :backup_payment => "MyString"
    ))
  end

  it "renders the edit account form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", account_path(@account), "post" do
      assert_select "input#account_account_id[name=?]", "account[account_id]"
      assert_select "input#account_credit_card[name=?]", "account[credit_card]"
      assert_select "input#account_default_account[name=?]", "account[default_account]"
      assert_select "input#account_backup_payment[name=?]", "account[backup_payment]"
    end
  end
end

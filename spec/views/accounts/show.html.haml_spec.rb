require 'spec_helper'

describe "accounts/show" do
  before(:each) do
    @account = assign(:account, stub_model(Account,
      :account_id => "Account",
      :credit_card => "Credit Card",
      :default_account => "Default Account",
      :backup_payment => "Backup Payment"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Account/)
    rendered.should match(/Credit Card/)
    rendered.should match(/Default Account/)
    rendered.should match(/Backup Payment/)
  end
end

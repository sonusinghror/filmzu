require 'spec_helper'

describe "accounts/index" do
  before(:each) do
    assign(:accounts, [
      stub_model(Account,
        :account_id => "Account",
        :credit_card => "Credit Card",
        :default_account => "Default Account",
        :backup_payment => "Backup Payment"
      ),
      stub_model(Account,
        :account_id => "Account",
        :credit_card => "Credit Card",
        :default_account => "Default Account",
        :backup_payment => "Backup Payment"
      )
    ])
  end

  it "renders a list of accounts" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Account".to_s, :count => 2
    assert_select "tr>td", :text => "Credit Card".to_s, :count => 2
    assert_select "tr>td", :text => "Default Account".to_s, :count => 2
    assert_select "tr>td", :text => "Backup Payment".to_s, :count => 2
  end
end

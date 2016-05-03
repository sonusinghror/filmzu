require 'spec_helper'

describe "disputes/new" do
  before(:each) do
    assign(:dispute, stub_model(Dispute,
      :dispute_id => 1,
      :dispute_description => "MyString"
    ).as_new_record)
  end

  it "renders new dispute form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", disputes_path, "post" do
      assert_select "input#dispute_dispute_id[name=?]", "dispute[dispute_id]"
      assert_select "input#dispute_dispute_description[name=?]", "dispute[dispute_description]"
    end
  end
end

require 'spec_helper'

describe "disputes/edit" do
  before(:each) do
    @dispute = assign(:dispute, stub_model(Dispute,
      :dispute_id => 1,
      :dispute_description => "MyString"
    ))
  end

  it "renders the edit dispute form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", dispute_path(@dispute), "post" do
      assert_select "input#dispute_dispute_id[name=?]", "dispute[dispute_id]"
      assert_select "input#dispute_dispute_description[name=?]", "dispute[dispute_description]"
    end
  end
end

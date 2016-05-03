require 'spec_helper'

describe "disputes/index" do
  before(:each) do
    assign(:disputes, [
      stub_model(Dispute,
        :dispute_id => 1,
        :dispute_description => "Dispute Description"
      ),
      stub_model(Dispute,
        :dispute_id => 1,
        :dispute_description => "Dispute Description"
      )
    ])
  end

  it "renders a list of disputes" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Dispute Description".to_s, :count => 2
  end
end

require 'spec_helper'

describe "disputes/show" do
  before(:each) do
    @dispute = assign(:dispute, stub_model(Dispute,
      :dispute_id => 1,
      :dispute_description => "Dispute Description"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/Dispute Description/)
  end
end

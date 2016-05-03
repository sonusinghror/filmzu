require 'spec_helper'

describe "milestones/edit" do
  before(:each) do
    @milestone = assign(:milestone, stub_model(Milestone,
      :title => "MyString",
      :description => "MyString"
    ))
  end

  it "renders the edit milestone form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", milestone_path(@milestone), "post" do
      assert_select "input#milestone_title[name=?]", "milestone[title]"
      assert_select "input#milestone_description[name=?]", "milestone[description]"
    end
  end
end

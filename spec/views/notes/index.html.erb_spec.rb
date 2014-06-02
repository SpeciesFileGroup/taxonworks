require 'spec_helper'

describe "notes/index" do
  before(:each) do
    assign(:notes, [
      stub_model(Note,
        :text => "Text",
        :note_object_id => 1,
        :note_object_type => "Note Object Type",
        :note_object_attribute => "Note Object Attribute",
        :created_by_id => 2,
        :updated_by_id => 3,
        :project_id => 4
      ),
      stub_model(Note,
        :text => "Text",
        :note_object_id => 1,
        :note_object_type => "Note Object Type",
        :note_object_attribute => "Note Object Attribute",
        :created_by_id => 2,
        :updated_by_id => 3,
        :project_id => 4
      )
    ])
  end

  it "renders a list of notes" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Text".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Note Object Type".to_s, :count => 2
    assert_select "tr>td", :text => "Note Object Attribute".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
  end
end

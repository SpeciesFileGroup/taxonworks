require 'rails_helper'

describe "tags/index", :type => :view do
  before(:each) do
    assign(:tags, [
      stub_model(Tag,
        :keyword_id => 1,
        :tag_object_id => 2,
        :tag_object_type => "Tag Object Type",
        :tag_object_attribute => "Tag Object Attribute",
        :created_by_id => 3,
        :updated_by_id => 4,
        :project_id => 5,
        :position => 6
      ),
      stub_model(Tag,
        :keyword_id => 1,
        :tag_object_id => 2,
        :tag_object_type => "Tag Object Type",
        :tag_object_attribute => "Tag Object Attribute",
        :created_by_id => 3,
        :updated_by_id => 4,
        :project_id => 5,
        :position => 6
      )
    ])
  end

  it "renders a list of tags" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Tag Object Type".to_s, :count => 2
    assert_select "tr>td", :text => "Tag Object Attribute".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => 6.to_s, :count => 2
  end
end

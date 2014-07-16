require 'rails_helper'

describe "tags/show" do
  before(:each) do
    @tag = assign(:tag, stub_model(Tag,
      :keyword_id => 1,
      :tag_object_id => 2,
      :tag_object_type => "Tag Object Type",
      :tag_object_attribute => "Tag Object Attribute",
      :created_by_id => 3,
      :updated_by_id => 4,
      :project_id => 5,
      :position => 6
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/Tag Object Type/)
    rendered.should match(/Tag Object Attribute/)
    rendered.should match(/3/)
    rendered.should match(/4/)
    rendered.should match(/5/)
    rendered.should match(/6/)
  end
end

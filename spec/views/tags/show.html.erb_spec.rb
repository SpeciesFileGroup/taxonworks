require 'rails_helper'

describe "tags/show", :type => :view do
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
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Tag Object Type/)
    expect(rendered).to match(/Tag Object Attribute/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(/6/)
  end
end

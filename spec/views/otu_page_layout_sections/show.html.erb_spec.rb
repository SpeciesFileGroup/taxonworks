require 'spec_helper'

describe "otu_page_layout_sections/show" do
  before(:each) do
    @otu_page_layout_section = assign(:otu_page_layout_section, stub_model(OtuPageLayoutSection,
      :otu_page_layout_id => 1,
      :type => "Type",
      :position => 2,
      :topic_id => 3,
      :dynamic_content_class => "Dynamic Content Class",
      :created_by_id => 4,
      :updated_by_id => 5,
      :project_id => 6
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/Type/)
    rendered.should match(/2/)
    rendered.should match(/3/)
    rendered.should match(/Dynamic Content Class/)
    rendered.should match(/4/)
    rendered.should match(/5/)
    rendered.should match(/6/)
  end
end

require 'rails_helper'

describe "otu_page_layout_sections/show", :type => :view do
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
    expect(rendered).to match(/1/)
    expect(rendered).to match(/Type/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/Dynamic Content Class/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(/6/)
  end
end

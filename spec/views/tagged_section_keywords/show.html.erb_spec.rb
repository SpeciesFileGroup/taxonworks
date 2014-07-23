require 'rails_helper'

describe "tagged_section_keywords/show", :type => :view do
  before(:each) do
    @tagged_section_keyword = assign(:tagged_section_keyword, stub_model(TaggedSectionKeyword,
      :otu_page_layout_section_id => 1,
      :position => 2,
      :created_by_id => 3,
      :updated_by_id => 4,
      :project_id => 5,
      :keyword_id => 6
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
    expect(rendered).to match(/6/)
  end
end

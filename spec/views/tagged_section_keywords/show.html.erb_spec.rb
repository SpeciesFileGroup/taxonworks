require 'rails_helper'

describe "tagged_section_keywords/show" do
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
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/3/)
    rendered.should match(/4/)
    rendered.should match(/5/)
    rendered.should match(/6/)
  end
end

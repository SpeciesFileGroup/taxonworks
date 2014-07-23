require 'rails_helper'

describe "tagged_section_keywords/index", :type => :view do
  before(:each) do
    assign(:tagged_section_keywords, [
      stub_model(TaggedSectionKeyword,
        :otu_page_layout_section_id => 1,
        :position => 2,
        :created_by_id => 3,
        :updated_by_id => 4,
        :project_id => 5,
        :keyword_id => 6
      ),
      stub_model(TaggedSectionKeyword,
        :otu_page_layout_section_id => 1,
        :position => 2,
        :created_by_id => 3,
        :updated_by_id => 4,
        :project_id => 5,
        :keyword_id => 6
      )
    ])
  end

  it "renders a list of tagged_section_keywords" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => 6.to_s, :count => 2
  end
end

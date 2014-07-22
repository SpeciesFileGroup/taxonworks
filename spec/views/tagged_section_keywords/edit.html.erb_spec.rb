require 'rails_helper'

describe "tagged_section_keywords/edit" do
  before(:each) do
    @tagged_section_keyword = assign(:tagged_section_keyword, stub_model(TaggedSectionKeyword,
      :otu_page_layout_section_id => 1,
      :position => 1,
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1,
      :keyword_id => 1
    ))
  end

  it "renders the edit tagged_section_keyword form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", tagged_section_keyword_path(@tagged_section_keyword), "post" do
      assert_select "input#tagged_section_keyword_otu_page_layout_section_id[name=?]", "tagged_section_keyword[otu_page_layout_section_id]"
      assert_select "input#tagged_section_keyword_position[name=?]", "tagged_section_keyword[position]"
      # assert_select "input#tagged_section_keyword_created_by_id[name=?]", "tagged_section_keyword[created_by_id]"
      # assert_select "input#tagged_section_keyword_updated_by_id[name=?]", "tagged_section_keyword[updated_by_id]"
      # assert_select "input#tagged_section_keyword_project_id[name=?]", "tagged_section_keyword[project_id]"
      assert_select "input#tagged_section_keyword_keyword_id[name=?]", "tagged_section_keyword[keyword_id]"
    end
  end
end

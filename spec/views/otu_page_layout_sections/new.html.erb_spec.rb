require 'rails_helper'

describe "otu_page_layout_sections/new" do
  before(:each) do
    assign(:otu_page_layout_section, stub_model(OtuPageLayoutSection,
      :otu_page_layout_id => 1,
      :type => "",
      :position => 1,
      :topic_id => 1,
      :dynamic_content_class => "MyString",
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1
    ).as_new_record)
  end

  it "renders new otu_page_layout_section form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", otu_page_layout_sections_path, "post" do
      assert_select "input#otu_page_layout_section_otu_page_layout_id[name=?]", "otu_page_layout_section[otu_page_layout_id]"
      assert_select "input#otu_page_layout_section_type[name=?]", "otu_page_layout_section[type]"
      assert_select "input#otu_page_layout_section_position[name=?]", "otu_page_layout_section[position]"
      assert_select "input#otu_page_layout_section_topic_id[name=?]", "otu_page_layout_section[topic_id]"
      assert_select "input#otu_page_layout_section_dynamic_content_class[name=?]", "otu_page_layout_section[dynamic_content_class]"
      # assert_select "input#otu_page_layout_section_created_by_id[name=?]", "otu_page_layout_section[created_by_id]"
      # assert_select "input#otu_page_layout_section_updated_by_id[name=?]", "otu_page_layout_section[updated_by_id]"
      # assert_select "input#otu_page_layout_section_project_id[name=?]", "otu_page_layout_section[project_id]"
    end
  end
end

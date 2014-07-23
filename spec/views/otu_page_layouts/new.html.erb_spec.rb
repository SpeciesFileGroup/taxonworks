require 'rails_helper'

describe "otu_page_layouts/new", :type => :view do
  before(:each) do
    assign(:otu_page_layout, stub_model(OtuPageLayout,
      :name => "MyString",
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1
    ).as_new_record)
  end

  it "renders new otu_page_layout form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", otu_page_layouts_path, "post" do
      assert_select "input#otu_page_layout_name[name=?]", "otu_page_layout[name]"
      # assert_select "input#otu_page_layout_created_by_id[name=?]", "otu_page_layout[created_by_id]"
      # assert_select "input#otu_page_layout_updated_by_id[name=?]", "otu_page_layout[updated_by_id]"
      # assert_select "input#otu_page_layout_project_id[name=?]", "otu_page_layout[project_id]"
    end
  end
end

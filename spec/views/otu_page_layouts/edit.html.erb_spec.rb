require 'rails_helper'

describe "otu_page_layouts/edit" do
  before(:each) do
    @otu_page_layout = assign(:otu_page_layout, stub_model(OtuPageLayout,
      :name => "MyString",
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1
    ))
  end

  it "renders the edit otu_page_layout form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", otu_page_layout_path(@otu_page_layout), "post" do
      assert_select "input#otu_page_layout_name[name=?]", "otu_page_layout[name]"
      # assert_select "input#otu_page_layout_created_by_id[name=?]", "otu_page_layout[created_by_id]"
      # assert_select "input#otu_page_layout_updated_by_id[name=?]", "otu_page_layout[updated_by_id]"
      # assert_select "input#otu_page_layout_project_id[name=?]", "otu_page_layout[project_id]"
    end
  end
end

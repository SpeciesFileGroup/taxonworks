require 'spec_helper'

describe "otu_page_layout_sections/new" do
  before(:each) do
    assign(:otu_page_layout_section, stub_model(OtuPageLayoutSection).as_new_record)
  end

  it "renders new otu_page_layout_section form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", otu_page_layout_sections_path, "post" do
    end
  end
end

require 'spec_helper'

describe "otu_page_layout_sections/edit" do
  before(:each) do
    @otu_page_layout_section = assign(:otu_page_layout_section, stub_model(OtuPageLayoutSection))
  end

  it "renders the edit otu_page_layout_section form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", otu_page_layout_section_path(@otu_page_layout_section), "post" do
    end
  end
end

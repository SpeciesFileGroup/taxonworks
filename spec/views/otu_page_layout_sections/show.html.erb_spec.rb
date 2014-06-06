require 'spec_helper'

describe "otu_page_layout_sections/show" do
  before(:each) do
    @otu_page_layout_section = assign(:otu_page_layout_section, stub_model(OtuPageLayoutSection))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end

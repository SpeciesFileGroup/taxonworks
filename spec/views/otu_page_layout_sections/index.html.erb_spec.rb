require 'spec_helper'

describe "otu_page_layout_sections/index" do
  before(:each) do
    assign(:otu_page_layout_sections, [
      stub_model(OtuPageLayoutSection),
      stub_model(OtuPageLayoutSection)
    ])
  end

  it "renders a list of otu_page_layout_sections" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end

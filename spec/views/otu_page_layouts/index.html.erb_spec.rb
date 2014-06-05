require 'spec_helper'

describe "otu_page_layouts/index" do
  before(:each) do
    assign(:otu_page_layouts, [
      stub_model(OtuPageLayout),
      stub_model(OtuPageLayout)
    ])
  end

  it "renders a list of otu_page_layouts" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end

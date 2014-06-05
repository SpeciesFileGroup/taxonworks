require 'spec_helper'

describe "otu_page_layouts/show" do
  before(:each) do
    @otu_page_layout = assign(:otu_page_layout, stub_model(OtuPageLayout))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end

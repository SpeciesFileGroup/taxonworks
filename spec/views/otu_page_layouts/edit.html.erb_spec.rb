require 'spec_helper'

describe "otu_page_layouts/edit" do
  before(:each) do
    @otu_page_layout = assign(:otu_page_layout, stub_model(OtuPageLayout))
  end

  it "renders the edit otu_page_layout form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", otu_page_layout_path(@otu_page_layout), "post" do
    end
  end
end

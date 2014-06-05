require 'spec_helper'

describe "otu_page_layouts/new" do
  before(:each) do
    assign(:otu_page_layout, stub_model(OtuPageLayout).as_new_record)
  end

  it "renders new otu_page_layout form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", otu_page_layouts_path, "post" do
    end
  end
end

require 'rails_helper'

describe "otu_page_layouts/show", :type => :view do
  before(:each) do
    @otu_page_layout = assign(:otu_page_layout, stub_model(OtuPageLayout,
      :name => "Name",
      :created_by_id => 1,
      :updated_by_id => 2,
      :project_id => 3
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/3/)
  end
end

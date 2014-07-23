require 'rails_helper'

describe "geographic_area_types/show", :type => :view do
  before(:each) do
    @geographic_area_type = assign(:geographic_area_type, stub_model(GeographicAreaType,
      :name => "Name",
      :created_by_id => 1,
      :updated_by_id => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/2/)
  end
end

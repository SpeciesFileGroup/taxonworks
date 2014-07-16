require 'rails_helper'

describe "geographic_area_types/show" do
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
    rendered.should match(/Name/)
    rendered.should match(/1/)
    rendered.should match(/2/)
  end
end

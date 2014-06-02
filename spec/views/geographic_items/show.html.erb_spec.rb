require 'spec_helper'

describe "geographic_items/show" do
  before(:each) do
    @geographic_item = assign(:geographic_item, stub_model(GeographicItem,
      :point => "",
      :line_string => "",
      :polygon => "",
      :multi_point => "",
      :multi_line_string => "",
      :multi_polygon => "",
      :geometry_collection => "",
      :created_by_id => 1,
      :updated_by_id => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(//)
    rendered.should match(/1/)
    rendered.should match(/2/)
  end
end

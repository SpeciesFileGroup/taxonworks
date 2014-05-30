require 'spec_helper'

describe "geographic_areas_geographic_items/show" do
  before(:each) do
    @geographic_areas_geographic_item = assign(:geographic_areas_geographic_item, stub_model(GeographicAreasGeographicItem,
      :geographic_area_id => 1,
      :geographic_item_id => 2,
      :data_origin => "Data Origin",
      :origin_gid => 3,
      :date_valid_from => "Date Valid From",
      :date_valid_to => "Date Valid To"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/Data Origin/)
    rendered.should match(/3/)
    rendered.should match(/Date Valid From/)
    rendered.should match(/Date Valid To/)
  end
end

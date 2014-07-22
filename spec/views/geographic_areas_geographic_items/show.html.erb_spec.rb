require 'rails_helper'

describe "geographic_areas_geographic_items/show" do
  before(:each) do
    @geographic_areas_geographic_item = assign(:geographic_areas_geographic_item,
                                               stub_model(GeographicAreasGeographicItem,
                                                          :geographic_area => stub_model(GeographicArea,
                                                                                         :name => 'Area 51'),
                                                          :geographic_item => stub_model(GeographicItem,
                                                                                         :id => 2),
                                                          :data_origin     => "Data Origin",
                                                          :origin_gid      => 3,
                                                          :date_valid_from => "Date Valid From",
                                                          :date_valid_to   => "Date Valid To"
                                               ))
  end

  it "renders attributes in <p>" do
    render
    # skip 'reconstruction of the geographic_areas_geographic_items/show view or spec'
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Area 51/)
    rendered.should match(/2/)
    rendered.should match(/Data Origin/)
    rendered.should match(/3/)
    rendered.should match(/Date Valid From/)
    rendered.should match(/Date Valid To/)
  end
end

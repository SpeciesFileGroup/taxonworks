require 'rails_helper'

describe "geographic_areas_geographic_items/show", :type => :view do
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
    expect(rendered).to match(/Area 51/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Data Origin/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/Date Valid From/)
    expect(rendered).to match(/Date Valid To/)
  end
end

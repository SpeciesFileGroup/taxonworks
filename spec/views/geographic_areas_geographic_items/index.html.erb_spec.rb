require 'spec_helper'

describe "geographic_areas_geographic_items/index" do
  before(:each) do
    assign(:geographic_areas_geographic_items, [
      stub_model(GeographicAreasGeographicItem,
        :geographic_area_id => 1,
        :geographic_item_id => 2,
        :data_origin => "Data Origin",
        :origin_gid => 3,
        :date_valid_from => "Date Valid From",
        :date_valid_to => "Date Valid To"
      ),
      stub_model(GeographicAreasGeographicItem,
        :geographic_area_id => 1,
        :geographic_item_id => 2,
        :data_origin => "Data Origin",
        :origin_gid => 3,
        :date_valid_from => "Date Valid From",
        :date_valid_to => "Date Valid To"
      )
    ])
  end

  it "renders a list of geographic_areas_geographic_items" do
    render
    pending 'reconstruction of the geographic_areas_geographic_items/index view'
# Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Data Origin".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => "Date Valid From".to_s, :count => 2
    assert_select "tr>td", :text => "Date Valid To".to_s, :count => 2
  end
end

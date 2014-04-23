require 'spec_helper'

describe "geographic_areas/index" do
  before(:each) do
    assign(:geographic_areas, [
      stub_model(GeographicArea,
        :name => "Name",
        :level0_id => 1,
        :level1_id => 2,
        :level2_id => 3,
        :gadm_geo_item_id => 4,
        :parent_id => 5,
        :geographic_area_type_id => 6,
        :iso_3166_a2 => "Iso 3166 A2",
        :rgt => 7,
        :lft => 8,
        :tdwg_parent_id => 9,
        :iso_3166_a3 => "Iso 3166 A3",
        :tdwg_geo_item_id => 10,
        :tdwgID => "Tdwg",
        :gadmID => 11,
        :gadm_valid_from => "Gadm Valid From",
        :gadm_valid_to => "Gadm Valid To",
        :data_origin => "Data Origin",
        :adm0_a3 => "Adm0 A3",
        :neID => "Ne",
        :created_by_id => 12,
        :updated_by_id => 13,
        :ne_geo_item_id => 14
      ),
      stub_model(GeographicArea,
        :name => "Name",
        :level0_id => 1,
        :level1_id => 2,
        :level2_id => 3,
        :gadm_geo_item_id => 4,
        :parent_id => 5,
        :geographic_area_type_id => 6,
        :iso_3166_a2 => "Iso 3166 A2",
        :rgt => 7,
        :lft => 8,
        :tdwg_parent_id => 9,
        :iso_3166_a3 => "Iso 3166 A3",
        :tdwg_geo_item_id => 10,
        :tdwgID => "Tdwg",
        :gadmID => 11,
        :gadm_valid_from => "Gadm Valid From",
        :gadm_valid_to => "Gadm Valid To",
        :data_origin => "Data Origin",
        :adm0_a3 => "Adm0 A3",
        :neID => "Ne",
        :created_by_id => 12,
        :updated_by_id => 13,
        :ne_geo_item_id => 14
      )
    ])
  end

  it "renders a list of geographic_areas" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => 6.to_s, :count => 2
    assert_select "tr>td", :text => "Iso 3166 A2".to_s, :count => 2
    assert_select "tr>td", :text => 7.to_s, :count => 2
    assert_select "tr>td", :text => 8.to_s, :count => 2
    assert_select "tr>td", :text => 9.to_s, :count => 2
    assert_select "tr>td", :text => "Iso 3166 A3".to_s, :count => 2
    assert_select "tr>td", :text => 10.to_s, :count => 2
    assert_select "tr>td", :text => "Tdwg".to_s, :count => 2
    assert_select "tr>td", :text => 11.to_s, :count => 2
    assert_select "tr>td", :text => "Gadm Valid From".to_s, :count => 2
    assert_select "tr>td", :text => "Gadm Valid To".to_s, :count => 2
    assert_select "tr>td", :text => "Data Origin".to_s, :count => 2
    assert_select "tr>td", :text => "Adm0 A3".to_s, :count => 2
    assert_select "tr>td", :text => "Ne".to_s, :count => 2
    assert_select "tr>td", :text => 12.to_s, :count => 2
    assert_select "tr>td", :text => 13.to_s, :count => 2
    assert_select "tr>td", :text => 14.to_s, :count => 2
  end
end

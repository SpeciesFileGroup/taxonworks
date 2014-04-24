require 'spec_helper'

describe "geographic_areas/show" do
  before(:each) do
    @geographic_area = assign(:geographic_area, stub_model(GeographicArea,
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
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/3/)
    rendered.should match(/4/)
    rendered.should match(/5/)
    rendered.should match(/6/)
    rendered.should match(/Iso 3166 A2/)
    rendered.should match(/7/)
    rendered.should match(/8/)
    rendered.should match(/9/)
    rendered.should match(/Iso 3166 A3/)
    rendered.should match(/10/)
    rendered.should match(/Tdwg/)
    rendered.should match(/11/)
    rendered.should match(/Gadm Valid From/)
    rendered.should match(/Gadm Valid To/)
    rendered.should match(/Data Origin/)
    rendered.should match(/Adm0 A3/)
    rendered.should match(/Ne/)
    rendered.should match(/12/)
    rendered.should match(/13/)
    rendered.should match(/14/)
  end
end

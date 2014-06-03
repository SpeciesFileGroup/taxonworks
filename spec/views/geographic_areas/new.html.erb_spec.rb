require 'spec_helper'

describe "geographic_areas/new" do
  before(:each) do
    assign(:geographic_area, stub_model(GeographicArea,
      :name => "MyString",
      :level0_id => 1,
      :level1_id => 1,
      :level2_id => 1,
      :gadm_geo_item_id => 1,
      :parent_id => 1,
      :geographic_area_type_id => 1,
      :iso_3166_a2 => "MyString",
      :tdwg_parent_id => 1,
      :iso_3166_a3 => "MyString",
      :tdwg_geo_item_id => 1,
      :tdwgID => "MyString",
      :gadmID => 1,
      :gadm_valid_from => "MyString",
      :gadm_valid_to => "MyString",
      :data_origin => "MyString",
      :adm0_a3 => "MyString",
      :neID => "MyString",
      :ne_geo_item_id => 1
    ).as_new_record)
  end

  it "renders new geographic_area form" do
    render

    pending 'reconstruction of the geographic_area/new view'
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", geographic_areas_path, "post" do
      assert_select "input#geographic_area_name[name=?]", "geographic_area[name]"
      assert_select "input#geographic_area_level0_id[name=?]", "geographic_area[level0_id]"
      assert_select "input#geographic_area_level1_id[name=?]", "geographic_area[level1_id]"
      assert_select "input#geographic_area_level2_id[name=?]", "geographic_area[level2_id]"
      assert_select "input#geographic_area_gadm_geo_item_id[name=?]", "geographic_area[gadm_geo_item_id]"
      assert_select "input#geographic_area_parent_id[name=?]", "geographic_area[parent_id]"
      assert_select "input#geographic_area_geographic_area_type_id[name=?]", "geographic_area[geographic_area_type_id]"
      assert_select "input#geographic_area_iso_3166_a2[name=?]", "geographic_area[iso_3166_a2]"
      assert_select "input#geographic_area_tdwg_parent_id[name=?]", "geographic_area[tdwg_parent_id]"
      assert_select "input#geographic_area_iso_3166_a3[name=?]", "geographic_area[iso_3166_a3]"
      assert_select "input#geographic_area_tdwg_geo_item_id[name=?]", "geographic_area[tdwg_geo_item_id]"
      assert_select "input#geographic_area_tdwgID[name=?]", "geographic_area[tdwgID]"
      assert_select "input#geographic_area_gadmID[name=?]", "geographic_area[gadmID]"
      assert_select "input#geographic_area_gadm_valid_from[name=?]", "geographic_area[gadm_valid_from]"
      assert_select "input#geographic_area_gadm_valid_to[name=?]", "geographic_area[gadm_valid_to]"
      assert_select "input#geographic_area_data_origin[name=?]", "geographic_area[data_origin]"
      assert_select "input#geographic_area_adm0_a3[name=?]", "geographic_area[adm0_a3]"
      assert_select "input#geographic_area_neID[name=?]", "geographic_area[neID]"
      assert_select "input#geographic_area_ne_geo_item_id[name=?]", "geographic_area[ne_geo_item_id]"
    end
  end
end

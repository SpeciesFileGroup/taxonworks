require 'spec_helper'

describe "geographic_areas_geographic_items/edit" do
  before(:each) do
    @geographic_areas_geographic_item = assign(:geographic_areas_geographic_item, stub_model(GeographicAreasGeographicItem,
      :geographic_area_id => 1,
      :geographic_item_id => 1,
      :data_origin => "MyString",
      :origin_gid => 1,
      :date_valid_from => "MyString",
      :date_valid_to => "MyString"
    ))
  end

  it "renders the edit geographic_areas_geographic_item form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", geographic_areas_geographic_item_path(@geographic_areas_geographic_item), "post" do
      assert_select "input#geographic_areas_geographic_item_geographic_area_id[name=?]", "geographic_areas_geographic_item[geographic_area_id]"
      assert_select "input#geographic_areas_geographic_item_geographic_item_id[name=?]", "geographic_areas_geographic_item[geographic_item_id]"
      assert_select "input#geographic_areas_geographic_item_data_origin[name=?]", "geographic_areas_geographic_item[data_origin]"
      assert_select "input#geographic_areas_geographic_item_origin_gid[name=?]", "geographic_areas_geographic_item[origin_gid]"
      assert_select "input#geographic_areas_geographic_item_date_valid_from[name=?]", "geographic_areas_geographic_item[date_valid_from]"
      assert_select "input#geographic_areas_geographic_item_date_valid_to[name=?]", "geographic_areas_geographic_item[date_valid_to]"
    end
  end
end

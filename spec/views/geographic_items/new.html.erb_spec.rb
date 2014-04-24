require 'spec_helper'

describe "geographic_items/new" do
  before(:each) do
    assign(:geographic_item, stub_model(GeographicItem,
      :point => "",
      :line_string => "",
      :polygon => "",
      :multi_point => "",
      :multi_line_string => "",
      :multi_polygon => "",
      :geometry_collection => "",
      :created_by_id => 1,
      :updated_by_id => 1
    ).as_new_record)
  end

  it "renders new geographic_item form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", geographic_items_path, "post" do
      assert_select "input#geographic_item_point[name=?]", "geographic_item[point]"
      assert_select "input#geographic_item_line_string[name=?]", "geographic_item[line_string]"
      assert_select "input#geographic_item_polygon[name=?]", "geographic_item[polygon]"
      assert_select "input#geographic_item_multi_point[name=?]", "geographic_item[multi_point]"
      assert_select "input#geographic_item_multi_line_string[name=?]", "geographic_item[multi_line_string]"
      assert_select "input#geographic_item_multi_polygon[name=?]", "geographic_item[multi_polygon]"
      assert_select "input#geographic_item_geometry_collection[name=?]", "geographic_item[geometry_collection]"
      assert_select "input#geographic_item_created_by_id[name=?]", "geographic_item[created_by_id]"
      assert_select "input#geographic_item_updated_by_id[name=?]", "geographic_item[updated_by_id]"
    end
  end
end

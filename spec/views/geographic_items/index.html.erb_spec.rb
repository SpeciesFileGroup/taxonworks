require 'spec_helper'

describe "geographic_items/index" do
  before(:each) do
    assign(:geographic_items, [
      stub_model(GeographicItem,
        :point => "",
        :line_string => "",
        :polygon => "",
        :multi_point => "",
        :multi_line_string => "",
        :multi_polygon => "",
        :geometry_collection => "",
        :created_by_id => 1,
        :updated_by_id => 2
      ),
      stub_model(GeographicItem,
        :point => "",
        :line_string => "",
        :polygon => "",
        :multi_point => "",
        :multi_line_string => "",
        :multi_polygon => "",
        :geometry_collection => "",
        :created_by_id => 1,
        :updated_by_id => 2
      )
    ])
  end

  it "renders a list of geographic_items" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end

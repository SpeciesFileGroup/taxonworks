require 'spec_helper'

describe "geographic_areas/index" do
  before(:each) do
    assign(:geographic_areas, [
      stub_model(GeographicArea,
                 :name                    => "Name",
                 :parent_id               => 1,
                 :geographic_area_type_id => 2,
                 :iso_3166_a2             => "Iso 3166 A2",
                 :iso_3166_a3             => "Iso 3166 A3",
                 :data_origin             => "Data Origin",
                 :level0_id               => 3,
                 :level1_id               => 4,
                 :level2_id               => 5,
                 :created_by_id           => 12,
                 :updated_by_id           => 13
      ),
      stub_model(GeographicArea,
                 :name                    => "Name",
                 :parent_id               => 1,
                 :geographic_area_type_id => 2,
                 :iso_3166_a2             => "Iso 3166 A2",
                 :iso_3166_a3             => "Iso 3166 A3",
                 :data_origin             => "Data Origin",
                 :level0_id               => 3,
                 :level1_id               => 4,
                 :level2_id               => 5,
                 :created_by_id           => 12,
                 :updated_by_id           => 13
      )
    ])
  end

  it "renders a list of geographic_areas" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Iso 3166 A2".to_s, :count => 2
    assert_select "tr>td", :text => "Iso 3166 A3".to_s, :count => 2
    assert_select "tr>td", :text => "Data Origin".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => 12.to_s, :count => 2
    assert_select "tr>td", :text => 13.to_s, :count => 2
  end
end

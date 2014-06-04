require 'spec_helper'

describe "georeferences/index" do
  before(:each) do
    assign(:georeferences, [
      stub_model(Georeference,
        :geographic_item_id => 1,
        :collecting_event_id => 2,
        :error_radius => "9.99",
        :error_depth => "9.99",
        :error_geographic_item_id => 3,
        :type => "Type",
        :source_id => 4,
        :position => 5,
        :is_public => false,
        :api_request => "Api Request",
        :created_by_id => 6,
        :updated_by_id => 7,
        :project_id => 8,
        :is_undefined_z => false,
        :is_median_z => false
      ),
      stub_model(Georeference,
        :geographic_item_id => 1,
        :collecting_event_id => 2,
        :error_radius => "9.99",
        :error_depth => "9.99",
        :error_geographic_item_id => 3,
        :type => "Type",
        :source_id => 4,
        :position => 5,
        :is_public => false,
        :api_request => "Api Request",
        :created_by_id => 6,
        :updated_by_id => 7,
        :project_id => 8,
        :is_undefined_z => false,
        :is_median_z => false
      )
    ])
  end

  it "renders a list of georeferences" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    pending 'reconstruction of the geographic_items/index view or spec'
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => "Api Request".to_s, :count => 2
    assert_select "tr>td", :text => 6.to_s, :count => 2
    assert_select "tr>td", :text => 7.to_s, :count => 2
    assert_select "tr>td", :text => 8.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end

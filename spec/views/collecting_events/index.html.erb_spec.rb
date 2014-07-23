require 'rails_helper'

describe "collecting_events/index", :type => :view do
  before(:each) do
    assign(:collecting_events, [
      stub_model(CollectingEvent,
        :verbatim_label => "MyText0",
        :print_label => "MyText1",
        :document_label => "MyText2",
        :verbatim_locality => "Verbatim Locality",
        :verbatim_longitude => "Verbatim Longitude",
        :verbatim_latitude => "Verbatim Latitude",
        :verbatim_geolocation_uncertainty => "Verbatim Geolocation Uncertainty",
        :verbatim_trip_identifier => "Verbatim Trip Identifier",
        :verbatim_collectors => "Verbatim Collectors",
        :verbatim_method => "Verbatim Method",
        :geographic_area_id => 2,
        :minimum_elevation => "9.99",
        :maximum_elevation => "9.99",
        :elevation_precision => "Elevation Precision",
        :start_date_day => "Start Date Day",
        :start_date_month => "Start Date Month",
        :start_date_year => "Start Date Year",
        :end_date_day => "End Date Day",
        :end_date_month => "End Date Month",
        :end_date_year => "End Date Year",
        :verbatim_habitat => "Verbatim Habitat",
        :field_notes => "MyText3",
        :md5_of_verbatim_label => "Md5 Of Verbatim Label",
        :cached_display => "MyText4",
        :created_by_id => 3,
        :updated_by_id => 4,
        :project_id => 5
      ),
      stub_model(CollectingEvent,
        :verbatim_label => "MyText0",
        :print_label => "MyText1",
        :document_label => "MyText2",
        :verbatim_locality => "Verbatim Locality",
        :verbatim_longitude => "Verbatim Longitude",
        :verbatim_latitude => "Verbatim Latitude",
        :verbatim_geolocation_uncertainty => "Verbatim Geolocation Uncertainty",
        :verbatim_trip_identifier => "Verbatim Trip Identifier",
        :verbatim_collectors => "Verbatim Collectors",
        :verbatim_method => "Verbatim Method",
        :geographic_area_id => 2,
        :minimum_elevation => "9.99",
        :maximum_elevation => "9.99",
        :elevation_precision => "Elevation Precision",
        :start_date_day => "Start Date Day",
        :start_date_month => "Start Date Month",
        :start_date_year => "Start Date Year",
        :end_date_day => "End Date Day",
        :end_date_month => "End Date Month",
        :end_date_year => "End Date Year",
        :verbatim_habitat => "Verbatim Habitat",
        :field_notes => "MyText3",
        :md5_of_verbatim_label => "Md5 Of Verbatim Label",
        :cached_display => "MyText4",
        :created_by_id => 3,
        :updated_by_id => 4,
        :project_id => 5
      )
    ])
  end

  it "renders a list of collecting_events" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText0".to_s, :count => 2
    assert_select "tr>td", :text => "MyText1".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "MyText2".to_s, :count => 2
    assert_select "tr>td", :text => "Verbatim Locality".to_s, :count => 2
    assert_select "tr>td", :text => "Verbatim Longitude".to_s, :count => 2
    assert_select "tr>td", :text => "Verbatim Latitude".to_s, :count => 2
    assert_select "tr>td", :text => "Verbatim Geolocation Uncertainty".to_s, :count => 2
    assert_select "tr>td", :text => "Verbatim Trip Identifier".to_s, :count => 2
    assert_select "tr>td", :text => "Verbatim Collectors".to_s, :count => 2
    assert_select "tr>td", :text => "Verbatim Method".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "9.99".to_s, :count => 4  #2
    #assert_select "tr>td", :text => "9.99".to_s, :count => 2
    # TODO: Matt To correct test error on above 2 lines, I commented one out and changed the count to 4 on the other. These correspond to min/max values that are the same.
    assert_select "tr>td", :text => "Elevation Precision".to_s, :count => 2
    skip 'reconstruction of the collecting_events/index view or spec'
    assert_select "tr>td", :text => "Start Date Day".to_s, :count => 2
    assert_select "tr>td", :text => "Start Date Month".to_s, :count => 2
    assert_select "tr>td", :text => "Start Date Year".to_s, :count => 2
    assert_select "tr>td", :text => "End Date Day".to_s, :count => 2
    assert_select "tr>td", :text => "End Date Month".to_s, :count => 2
    assert_select "tr>td", :text => "End Date Year".to_s, :count => 2
    assert_select "tr>td", :text => "Micro Habitat".to_s, :count => 2
    assert_select "tr>td", :text => "Macro Habitat".to_s, :count => 2
    assert_select "tr>td", :text => "MyText3".to_s, :count => 2
    assert_select "tr>td", :text => "Md5 Of Verbatim Label".to_s, :count => 2
    assert_select "tr>td", :text => "MyText4".to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => 4.to_s, :count => 2
    assert_select "tr>td", :text => 5.to_s, :count => 2
  end
end

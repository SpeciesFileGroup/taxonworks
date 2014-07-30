require 'rails_helper'

describe "collecting_events/index", :type => :view do
  before(:each) do
    @data_model = CollectingEvent
    assign(:recent_objects, [
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
        :project_id => 5,
        created_at: Time.now,
        updated_at: Time.now
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
        :project_id => 5,
        created_at: Time.now,
        updated_at: Time.now
                )
    ])
  end

  # TODO: Test does nothing, fix
  it "renders a list of recent collecting_events" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "ul>li",  :count => 2
  end
end

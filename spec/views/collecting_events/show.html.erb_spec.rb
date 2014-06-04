require 'spec_helper'

describe "collecting_events/show" do
  before(:each) do
    @collecting_event = assign(:collecting_event, stub_model(CollectingEvent,
      :verbatim_label => "MyText",
      :print_label => "MyText",
      :print_label_number_to_print => 1,
      :document_label => "MyText",
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
      :elevation_unit => "Elevation Unit",
      :elevation_precision => "Elevation Precision",
      :start_date_day => "Start Date Day",
      :start_date_month => "Start Date Month",
      :start_date_year => "Start Date Year",
      :end_date_day => "End Date Day",
      :end_date_month => "End Date Month",
      :end_date_year => "End Date Year",
      :micro_habitat => "Micro Habitat",
      :macro_habitat => "Macro Habitat",
      :field_notes => "MyText",
      :md5_of_verbatim_label => "Md5 Of Verbatim Label",
      :cached_display => "MyText",
      :created_by_id => 3,
      :updated_by_id => 4,
      :project_id => 5
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
    rendered.should match(/MyText/)
    rendered.should match(/1/)
    rendered.should match(/MyText/)
    rendered.should match(/Verbatim Locality/)
    rendered.should match(/Verbatim Longitude/)
    rendered.should match(/Verbatim Latitude/)
    rendered.should match(/Verbatim Geolocation Uncertainty/)
    rendered.should match(/Verbatim Trip Identifier/)
    rendered.should match(/Verbatim Collectors/)
    rendered.should match(/Verbatim Method/)
    rendered.should match(/2/)
    rendered.should match(/9.99/)
    rendered.should match(/9.99/)
    rendered.should match(/Elevation Unit/)
    rendered.should match(/Elevation Precision/)
    pending 'reconstruction of the collecting_events/show view or spec'
    rendered.should match(/Start Date Day/)
    rendered.should match(/Start Date Month/)
    rendered.should match(/Start Date Year/)
    rendered.should match(/End Date Day/)
    rendered.should match(/End Date Month/)
    rendered.should match(/End Date Year/)
    rendered.should match(/Micro Habitat/)
    rendered.should match(/Macro Habitat/)
    rendered.should match(/MyText/)
    rendered.should match(/Md5 Of Verbatim Label/)
    rendered.should match(/MyText/)
    rendered.should match(/3/)
    rendered.should match(/4/)
    rendered.should match(/5/)
  end
end

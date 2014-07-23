require 'rails_helper'

describe "collecting_events/show", :type => :view do
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
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/1/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Verbatim Locality/)
    expect(rendered).to match(/Verbatim Longitude/)
    expect(rendered).to match(/Verbatim Latitude/)
    expect(rendered).to match(/Verbatim Geolocation Uncertainty/)
    expect(rendered).to match(/Verbatim Trip Identifier/)
    expect(rendered).to match(/Verbatim Collectors/)
    expect(rendered).to match(/Verbatim Method/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/9.99/)
    expect(rendered).to match(/Elevation Precision/)
    skip 'reconstruction of the collecting_events/show view or spec'
    expect(rendered).to match(/Start Date Day/)
    expect(rendered).to match(/Start Date Month/)
    expect(rendered).to match(/Start Date Year/)
    expect(rendered).to match(/End Date Day/)
    expect(rendered).to match(/End Date Month/)
    expect(rendered).to match(/End Date Year/)
    expect(rendered).to match(/Micro Habitat/)
    expect(rendered).to match(/Macro Habitat/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/Md5 Of Verbatim Label/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/3/)
    expect(rendered).to match(/4/)
    expect(rendered).to match(/5/)
  end
end

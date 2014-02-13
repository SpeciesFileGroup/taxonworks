require 'spec_helper'

describe "collecting_events/edit" do
  before(:each) do
    @collecting_event = assign(:collecting_event, stub_model(CollectingEvent,
      :verbatim_label => "MyText",
      :print_label => "MyText",
      :print_label_number_to_print => 1,
      :document_label => "MyText",
      :verbatim_locality => "MyString",
      :verbatim_longitude => "MyString",
      :verbatim_latitude => "MyString",
      :verbatim_geolocation_uncertainty => "MyString",
      :verbatim_trip_identifier => "MyString",
      :verbatim_collectors => "MyString",
      :verbatim_method => "MyString",
      :geographic_area_id => 1,
      :minimum_elevation => "9.99",
      :maximum_elevation => "9.99",
      :elevation_unit => "MyString",
      :elevation_precision => "MyString",
      :start_date_day => "MyString",
      :start_date_month => "MyString",
      :start_date_year => "MyString",
      :end_date_day => "MyString",
      :end_date_month => "MyString",
      :end_date_year => "MyString",
      :micro_habitat => "MyString",
      :macro_habitat => "MyString",
      :field_notes => "MyText",
      :md5_of_verbatim_label => "MyString",
      :cached_display => "MyText",
      :created_by_id => 1,
      :updated_by_id => 1,
      :project_id => 1
    ))
  end

  it "renders the edit collecting_event form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", collecting_event_path(@collecting_event), "post" do
      assert_select "textarea#collecting_event_verbatim_label[name=?]", "collecting_event[verbatim_label]"
      assert_select "textarea#collecting_event_print_label[name=?]", "collecting_event[print_label]"
      assert_select "input#collecting_event_print_label_number_to_print[name=?]", "collecting_event[print_label_number_to_print]"
      assert_select "textarea#collecting_event_document_label[name=?]", "collecting_event[document_label]"
      assert_select "input#collecting_event_verbatim_locality[name=?]", "collecting_event[verbatim_locality]"
      assert_select "input#collecting_event_verbatim_longitude[name=?]", "collecting_event[verbatim_longitude]"
      assert_select "input#collecting_event_verbatim_latitude[name=?]", "collecting_event[verbatim_latitude]"
      assert_select "input#collecting_event_verbatim_geolocation_uncertainty[name=?]", "collecting_event[verbatim_geolocation_uncertainty]"
      assert_select "input#collecting_event_verbatim_trip_identifier[name=?]", "collecting_event[verbatim_trip_identifier]"
      assert_select "input#collecting_event_verbatim_collectors[name=?]", "collecting_event[verbatim_collectors]"
      assert_select "input#collecting_event_verbatim_method[name=?]", "collecting_event[verbatim_method]"
      assert_select "input#collecting_event_geographic_area_id[name=?]", "collecting_event[geographic_area_id]"
      assert_select "input#collecting_event_minimum_elevation[name=?]", "collecting_event[minimum_elevation]"
      assert_select "input#collecting_event_maximum_elevation[name=?]", "collecting_event[maximum_elevation]"
      assert_select "input#collecting_event_elevation_unit[name=?]", "collecting_event[elevation_unit]"
      assert_select "input#collecting_event_elevation_precision[name=?]", "collecting_event[elevation_precision]"
      assert_select "input#collecting_event_start_date_day[name=?]", "collecting_event[start_date_day]"
      assert_select "input#collecting_event_start_date_month[name=?]", "collecting_event[start_date_month]"
      assert_select "input#collecting_event_start_date_year[name=?]", "collecting_event[start_date_year]"
      assert_select "input#collecting_event_end_date_day[name=?]", "collecting_event[end_date_day]"
      assert_select "input#collecting_event_end_date_month[name=?]", "collecting_event[end_date_month]"
      assert_select "input#collecting_event_end_date_year[name=?]", "collecting_event[end_date_year]"
      assert_select "input#collecting_event_micro_habitat[name=?]", "collecting_event[micro_habitat]"
      assert_select "input#collecting_event_macro_habitat[name=?]", "collecting_event[macro_habitat]"
      assert_select "textarea#collecting_event_field_notes[name=?]", "collecting_event[field_notes]"
      assert_select "input#collecting_event_md5_of_verbatim_label[name=?]", "collecting_event[md5_of_verbatim_label]"
      assert_select "textarea#collecting_event_cached_display[name=?]", "collecting_event[cached_display]"
      assert_select "input#collecting_event_created_by_id[name=?]", "collecting_event[created_by_id]"
      assert_select "input#collecting_event_updated_by_id[name=?]", "collecting_event[updated_by_id]"
      assert_select "input#collecting_event_project_id[name=?]", "collecting_event[project_id]"
    end
  end
end

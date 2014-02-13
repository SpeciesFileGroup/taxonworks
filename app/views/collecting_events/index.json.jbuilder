json.array!(@collecting_events) do |collecting_event|
  json.extract! collecting_event, :id, :verbatim_label, :print_label, :print_label_number_to_print, :document_label, :verbatim_locality, :verbatim_longitude, :verbatim_latitude, :verbatim_geolocation_uncertainty, :verbatim_trip_identifier, :verbatim_collectors, :verbatim_method, :geographic_area_id, :minimum_elevation, :maximum_elevation, :elevation_unit, :elevation_precision, :time_start, :time_end, :start_date_day, :start_date_month, :start_date_year, :end_date_day, :end_date_month, :end_date_year, :micro_habitat, :macro_habitat, :field_notes, :md5_of_verbatim_label, :cached_display, :created_by_id, :updated_by_id, :project_id
  json.url collecting_event_url(collecting_event, format: :json)
end

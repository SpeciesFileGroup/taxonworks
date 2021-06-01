json.extract! collecting_event, :id, 
  :verbatim_label, :print_label, :document_label, 
  :verbatim_locality, :verbatim_longitude, :verbatim_latitude, :verbatim_geolocation_uncertainty, :verbatim_trip_identifier, :verbatim_collectors, :verbatim_method, 
  :verbatim_elevation, :verbatim_habitat, :verbatim_datum, :verbatim_date,
  :geographic_area_id, :minimum_elevation, :maximum_elevation, :elevation_precision, 
  :start_date_day, :start_date_month, :start_date_year, :end_date_day, :end_date_month, :end_date_year,
  :time_start_hour,
  :time_start_minute,  
  :time_start_second, 
  :time_end_hour,      
  :time_end_minute,    
  :time_end_second, 
  :field_notes, :md5_of_verbatim_label,
  :min_ma, :max_ma,
  :cached, 
  :cached_level0_geographic_name,
  :cached_level1_geographic_name,
  :cached_level2_geographic_name,
  :group,
  :formation,
  :member,   
  :lithology,
  :max_ma,  
  :min_ma,
  :identifiers,
  :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.global_id collecting_event.to_global_id.to_s

if collecting_event.roles.any?
  json.collector_roles do
    json.array! collecting_event.collector_roles.each do |role|
      json.extract! role, :id, :position, :type
      json.partial! '/people/api/v1/brief', person: role.person
    end
  end
end 





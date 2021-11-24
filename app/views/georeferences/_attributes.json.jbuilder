json.extract! georeference, :id, :geographic_item_id, :collecting_event_id,  :type,
  :error_radius, :error_depth, :error_geographic_item_id, 
   :position, :is_public, :api_request, 
   :is_undefined_z, :is_median_z, 
   :year_georeferenced, :month_georeferenced, :day_georeferenced,
   :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
   
json.partial! '/shared/data/all/metadata', object: georeference #, klass: 'Georeference'

json.geo_json georeference.to_geo_json_feature # check this

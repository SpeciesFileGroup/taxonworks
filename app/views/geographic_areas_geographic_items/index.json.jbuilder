json.array!(@geographic_areas_geographic_items) do |geographic_areas_geographic_item|
  json.extract! geographic_areas_geographic_item, :id, :geographic_area_id, :geographic_item_id, :data_origin, :origin_gid, :date_valid_from, :date_valid_to
  json.url geographic_areas_geographic_item_url(geographic_areas_geographic_item, format: :json)
end

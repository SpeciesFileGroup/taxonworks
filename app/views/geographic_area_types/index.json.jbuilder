json.array!(@geographic_area_types) do |geographic_area_type|
  json.extract! geographic_area_type, :id, :name, :created_by_id, :updated_by_id
  json.url geographic_area_type_url(geographic_area_type, format: :json)
end

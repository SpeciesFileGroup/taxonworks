json.extract! geographic_area, :id, :name, :level0_id, :level1_id, :level2_id,
  :parent_id, :geographic_area_type_id,
  :iso_3166_a2, :iso_3166_a3,
  :tdwgID, :data_origin,
  :created_by_id, :updated_by_id, :created_at, :updated_at

if embed_response_with('level_names')
  json.level0_name geographic_area.level0&.name
  json.level1_name geographic_area.level1&.name
  json.level2_name geographic_area.level2&.name
end

if embed_response_with('shape')
  json.shape geographic_area.to_geo_json_feature
end

if extend_response_with('geographic_area_type')
  json.geographic_area_type do
    json.extract! geographic_area.geographic_area_type, :id, :name
  end
end

if extend_response_with('parent')
  if geographic_area.parent_id
    json.parent do
      json.extract! geographic_area.parent, :name
    end
  end
end

json.array!(@geographic_areas) do |geographic_area|
  json.extract! geographic_area, :id, :name, :level0_id, :level1_id, :level2_id, :parent_id, :geographic_area_type_id,
    :iso_3166_a2, :iso_3166_a3, :tdwgID, :data_origin,  :created_by_id, :updated_by_id
  json.url geographic_area_url(geographic_area, format: :json)
end

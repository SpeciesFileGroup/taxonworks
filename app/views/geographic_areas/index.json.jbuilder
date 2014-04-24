json.array!(@geographic_areas) do |geographic_area|
  json.extract! geographic_area, :id, :name, :level0_id, :level1_id, :level2_id, :gadm_geo_item_id, :parent_id, :geographic_area_type_id, :iso_3166_a2, :rgt, :lft, :tdwg_parent_id, :iso_3166_a3, :tdwg_geo_item_id, :tdwgID, :gadmID, :gadm_valid_from, :gadm_valid_to, :data_origin, :adm0_a3, :neID, :created_by_id, :updated_by_id, :ne_geo_item_id
  json.url geographic_area_url(geographic_area, format: :json)
end

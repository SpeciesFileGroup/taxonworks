json.array!(@geographic_items) do |geographic_item|
  json.extract! geographic_item, :id, :point, :line_string, :polygon, :multi_point, :multi_line_string, :multi_polygon, :geometry_collection, :created_by_id, :updated_by_id
  json.url geographic_item_url(geographic_item, format: :json)
end

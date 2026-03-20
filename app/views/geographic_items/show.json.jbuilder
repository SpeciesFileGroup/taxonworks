json.extract! @geographic_item, :id, :type, :created_by_id, :updated_by_id, :created_at, :updated_at
json.wkt @geographic_item.to_wkt

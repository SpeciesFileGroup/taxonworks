json.array!(@container_items) do |container_item|
  json.extract! container_item, :id, :container_id, :position, :contained_object_id, :contained_object_type, :localization, :created_by_id, :updated_by_id, :project_id
  json.url container_item_url(container_item, format: :json)
end

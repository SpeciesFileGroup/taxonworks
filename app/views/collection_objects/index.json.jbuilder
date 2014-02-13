json.array!(@collection_objects) do |collection_object|
  json.extract! collection_object, :id, :total, :type, :preparation_type_id, :repository_id, :created_by_id, :updated_by_id, :project_id
  json.url collection_object_url(collection_object, format: :json)
end

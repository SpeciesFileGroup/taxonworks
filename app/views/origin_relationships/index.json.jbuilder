json.array!(@origin_relationships) do |origin_relationship|
  json.extract! origin_relationship, :id, :old_object, :new_object, :position, :created_by_id, :updated_by_id, :project_id
  json.url origin_relationship_url(origin_relationship, format: :json)
end

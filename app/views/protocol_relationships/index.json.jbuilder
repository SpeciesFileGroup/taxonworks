json.array!(@protocol_relationships) do |protocol_relationship|
  json.extract! protocol_relationship, :id, :protocol_id, :protocol_relationship_object, :type, :position, :created_by_id, :updated_by_id, :project_id
  json.url protocol_relationship_url(protocol_relationship, format: :json)
end

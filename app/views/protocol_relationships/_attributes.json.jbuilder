json.extract! protocol_relationship, :id, :protocol_id, :position, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.partial! '/shared/data/all/metadata', object: protocol_relationship 

if extend_response_with('protocol_relationship_object')
  json.protocol_relationship_object do
    json.partial! '/shared/data/all/metadata', object: protocol_relationship.protocol_relationship_object, extensions: false
  end
end

if extend_response_with('protocol')
  json.protocol do
    json.partial! '/shared/data/all/metadata', object: protocol_relationship.protocol, extensions: false
  end
end

json.extract! identifier, :id, :identifier_object_id, :identifier_object_type, :identifier, :position, :type, :cached, :namespace_id, :created_by_id, :updated_by_id

json.partial! '/shared/data/all/metadata', object: identifier

json.identifier_object do
  json.partial! '/shared/data/all/metadata', object: identifier.identifier_object, extensions: false
end

if extend_response_with('annotated_object')
  json.annotated_object do
    json.partial! '/shared/data/all/metadata', object: metamorphosize_if(identifier.identifier_object), extensions: false
  end
end

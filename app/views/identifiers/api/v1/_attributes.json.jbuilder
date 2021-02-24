json.extract! identifier, :id, :identifier_object_id, :identifier_object_type, :identifier, :type, :cached, :namespace_id, :created_by_id, :updated_by_id

json.identifier_object do
  json.id identifier.identifier_object_id 
  json.type identifier.identifier_object_type
  json.type identifier.identifier_object.to_global_id.to_s
end

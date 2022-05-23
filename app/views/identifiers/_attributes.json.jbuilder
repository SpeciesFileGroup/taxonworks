json.extract! identifier, :id, :identifier_object_id, :identifier_object_type, :identifier, :type, :cached, :namespace_id, :created_by_id, :updated_by_id

json.partial! '/shared/data/all/metadata', object: identifier

json.identifier_object do 
  json.partial! '/shared/data/all/metadata', object: identifier.identifier_object, extension: false
end

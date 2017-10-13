json.extract! identifier, :id, :identifier_object_id, :identifier_object_type, :identifier, :type, :cached, :namespace_id, :created_by_id, :updated_by_id
json.object_tag identifier_tag(identifier)
json.url identifier_url(identifier, format: :json)


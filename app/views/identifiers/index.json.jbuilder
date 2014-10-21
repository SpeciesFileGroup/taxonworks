json.array!(@identifiers) do |identifier|
  json.extract! identifier, :id, :identified_object_id, :identified_object_type, :identifier, :type, :cached, :namespace_id, :created_by_id, :updated_by_id
  json.url identifier_url(identifier, format: :json)
end

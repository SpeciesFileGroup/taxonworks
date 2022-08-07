json.extract! identifier, :id, :identifier_object_id, :identifier_object_type, :identifier, :type, :cached, :namespace_id, :created_by_id, :updated_by_id
json.identifier_object_global_id identifier.identifier_object.to_global_id.to_s

if extend_response_with('namespace')
  if identifier.namespace
    json.namespace do
      json.extract! identifier.namespace, :id, :name, :short_name, :delimiter, :institution, :verbatim_short_name
    end
  end
end



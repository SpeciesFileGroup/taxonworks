json.array!(@namespaces) do |namespace|
  json.extract! namespace, :id, :institution, :name, :short_name, :verbatim_short_name, :delimiter, :is_virtual, :created_by_id, :updated_by_id
  json.global_id namespace.to_global_id.to_s
  json.url namespace_url(namespace, format: :json)
end

json.array!(@namespaces) do |namespace|
  json.extract! namespace, :id, :institution, :name, :short_name, :created_by_id, :updated_by_id
  json.url namespace_url(namespace, format: :json)
end

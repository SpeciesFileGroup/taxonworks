json.extract! namespace, :id, :institution, :name, :short_name, :verbatim_short_name, :is_virtual, :created_by_id, :updated_by_id, :created_at, :updated_at

json.object_tag namespace_tag(namespace)
json.url namespace_url(namespace, format: :json)
json.global_id namespace.to_global_id.to_s
json.type 'Namespace'

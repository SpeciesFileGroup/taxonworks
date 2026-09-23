json.extract! asserted_environment, :id, :asserted_environment_object_id, :asserted_environment_object_type,
  :uri, :uri_label, :position, :cached, :created_at, :updated_at

json.url asserted_environment_url(asserted_environment, format: :json)

json.asserted_environment_object do
  json.global_id asserted_environment.asserted_environment_object.to_global_id.to_s
  json.object_tag object_tag(asserted_environment.asserted_environment_object)
end

json.partial! '/shared/data/all/metadata', object: asserted_environment

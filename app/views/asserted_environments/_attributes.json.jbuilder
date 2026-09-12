json.extract! asserted_environment, :id, :asserted_environment_object_id, :asserted_environment_object_type,
  :uri, :uri_label, :position, :cached, :created_at, :updated_at

json.url asserted_environment_url(asserted_environment, format: :json)

json.partial! '/shared/data/all/metadata', object: asserted_environment

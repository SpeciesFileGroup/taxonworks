json.array!(@protocols) do |protocol|
  json.extract! protocol, :id, :name, :short_name, :description, :created_by_id, :updated_by_id, :project_id
  json.url protocol_url(protocol, format: :json)
end

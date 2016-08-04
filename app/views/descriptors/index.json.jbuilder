json.array!(@descriptors) do |descriptor|
  json.extract! descriptor, :id, :name, :short_name, :type, :created_by_id, :updated_by_id, :project_id
  json.url descriptor_url(descriptor, format: :json)
end

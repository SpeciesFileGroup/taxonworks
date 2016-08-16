json.array!(@descriptors) do |descriptor|
  json.extract! descriptor, :id, :descriptor_id, :created_by_id, :updated_by_id, :project_id
  json.url descriptor_url(descriptor, format: :json)
end

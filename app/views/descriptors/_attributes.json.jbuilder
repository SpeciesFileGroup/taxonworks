json.extract! descriptor, :id, :name, :short_name, :type, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.object_tag descriptor_tag(descriptor)
json.url descriptor_url(descriptor, format: :json)

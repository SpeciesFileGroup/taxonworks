json.extract! documentation, :id, :documentation_object_id, :documentation_object_type, :document_id, :page_map, :project_id, :created_by_id, :updated_by_id, :created_at, :updated_at
json.object_tag documentation_tag(documentation)
json.url documentation_url(documentation, format: :json)


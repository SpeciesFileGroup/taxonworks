json.array!(@citations) do |citation|
  json.extract! citation, :id, :citation_object_id, :citation_object_type, :source_id, :created_by_id, :updated_by_id, :project_id
  json.url citation_url(citation, format: :json)
end

json.array!(@contents) do |content|
  json.extract! content, :id, :text, :otu_id, :topic_id, :type, :created_by_id, :updated_by_id, :project_id, :revision_id
  json.url content_url(content, format: :json)
end

json.array!(@citation_topics) do |citation_topic|
  json.extract! citation_topic, :id, :topic_id, :citation_id, :pages, :created_by_id, :updated_by_id, :project_id
  json.url citation_topic_url(citation_topic, format: :json)
end

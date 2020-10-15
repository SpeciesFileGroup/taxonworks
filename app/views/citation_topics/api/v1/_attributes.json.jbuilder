json.extract! citation_topic, :id, :citation_id, :topic_id, :pages, :created_by_id, :updated_by_id, :project_id
json.url citation_topic_url(citation_topic, format: :json)

json.topic do |t|
  t.partial! '/controlled_vocabulary_terms/attributes', controlled_vocabulary_term: citation_topic.topic
end


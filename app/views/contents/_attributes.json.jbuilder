json.extract! content, :id, :text, :otu_id, :topic_id, :created_by_id, :updated_by_id, :project_id, :revision_id, :created_at, :updated_at
json.object_tag taxon_works_content_tag(content)
json.url content_url(content, format: :json)

json.otu do
  json.partial! '/otus/attributes', otu: content.otu
end

json.topic do
  json.partial! '/controlled_vocabulary_terms/attributes', controlled_vocabulary_term: content.topic
end



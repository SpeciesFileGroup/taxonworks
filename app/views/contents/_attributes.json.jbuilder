json.extract! content, :id, :text, :otu_id, :topic_id, :created_by_id, :updated_by_id, :project_id, :revision_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: content 

json.otu do
  json.partial! '/otus/attributes', otu: content.otu
end

json.topic do
  json.partial! '/controlled_vocabulary_terms/attributes', controlled_vocabulary_term: content.topic
end



json.extract! content, :id, :text, :otu_id, :topic_id, :created_by_id, :updated_by_id, :project_id, :revision_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: content

if extend_response_with('public_content')
  if content.public_content
    json.public_content do
      json.partial! '/public_contents/attributes', public_content: content.public_content
    end
  end
end

if extend_response_with('otu')
  json.otu do
    json.partial! '/otus/attributes', otu: content.otu, extensions: false
  end
end

if extend_response_with('topic')
  json.topic do
    json.partial! '/controlled_vocabulary_terms/attributes', controlled_vocabulary_term: content.topic, extensions: false
  end
end


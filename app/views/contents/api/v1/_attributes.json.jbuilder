json.extract! content, :id, :text, :otu_id, :topic_id, :created_by_id, :updated_by_id, :project_id, :revision_id, :created_at, :updated_at

json.global_id content.to_global_id.to_s

json.otu do
  json.global_id content.otu.to_global_id.to_s
end

json.topic do
  json.global_id content.topic.to_global_id.to_s
  json.uri content.topic.uri
end

if extend_response_with('citations') && content.has_citations?
  json.citations do
    json.array! content.citations do |citation|
      json.partial! '/citations/api/v1/attributes', citation: citation, extensions: false
      json.source do
        json.partial! '/sources/api/v1/base_attributes', source: citation.source
      end
    end
  end
end

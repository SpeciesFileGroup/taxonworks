json.extract! citation, :id, :citation_object_id, :citation_object_type, :source_id, :pages, :is_original,
  :created_by_id, :updated_by_id, :project_id

json.citation_object do
  json.id citation.citation_object_id
  json.type citation.citation_object_type
  json.global_id citation.citation_object.to_global_id.to_s
end

json.citation_topics do |ct|
  ct.array! citation.citation_topics, partial: '/citation_topics/api/v1/attributes', as: :citation_topic
end

json.source do
  json.name citation.source.cached
  json.global_id citation.source.to_global_id.to_s
end

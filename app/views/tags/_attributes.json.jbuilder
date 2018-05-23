json.extract! tag, :id, :tag_object_type, :tag_object_attribute, :tag_object_id, :keyword_id, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.object_tag tag_tag(tag)
json.url tag_url(tag, format: :json)

json.keyword do
  json.partial! '/controlled_vocabulary_terms/attributes', controlled_vocabulary_term: tag.keyword
end


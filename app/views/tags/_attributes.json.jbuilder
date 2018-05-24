json.extract! tag, :id, :tag_object_type, :tag_object_attribute, :tag_object_id, :keyword_id, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: tag 

json.annotated_object do
  json.partial! '/shared/data/all/metadata', object: metamorphosize_if(tag.tag_object)
end

json.keyword do
  json.partial! '/controlled_vocabulary_terms/attributes', controlled_vocabulary_term: tag.keyword
end


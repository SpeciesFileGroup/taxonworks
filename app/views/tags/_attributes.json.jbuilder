json.extract! tag, :id, :tag_object_type, :tag_object_attribute, :tag_object_id, :keyword_id, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: tag 
json.annotated_object_global_id tag.tag_object.to_global_id.to_s
json.annotated_object_url url_for(tag.tag_object.metamorphosize)


json.keyword do
  json.partial! '/controlled_vocabulary_terms/attributes', controlled_vocabulary_term: tag.keyword
end


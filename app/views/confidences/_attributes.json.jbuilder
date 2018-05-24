json.extract! confidence, :id, :confidence_object_id, :confidence_object_type, :confidence_level_id, :position, :created_by_id, :updated_by_id, :created_at, :updated_at, :project_id

json.partial! '/shared/data/all/metadata', object: confidence

json.annotated_object do
  json.partial! '/shared/data/all/metadata', object: metamorphosize_if(confidence.confidence_object) 
end

json.confidence_level do
  json.partial! '/controlled_vocabulary_terms/attributes', controlled_vocabulary_term: confidence.confidence_level
end

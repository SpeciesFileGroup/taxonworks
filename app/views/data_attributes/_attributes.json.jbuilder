json.extract! data_attribute, :id, :type, :attribute_subject_id, :attribute_subject_type, :controlled_vocabulary_term_id, :import_predicate, :value, :created_at, :updated_at, :created_by_id, :updated_by_id, :project_id
json.predicate_name data_attribute.predicate_name

json.partial! '/shared/data/all/metadata', object: data_attribute

# TODO 
if extend_response_with('annotated_object')
  json.annotated_object do
    json.partial! '/shared/data/all/metadata', object: metamorphosize_if(data_attribute.attribute_subject)
  end
end

if data_attribute.editable?
  json.controlled_vocabulary_term do
    json.partial! '/controlled_vocabulary_terms/attributes', controlled_vocabulary_term: data_attribute.predicate
  end
end

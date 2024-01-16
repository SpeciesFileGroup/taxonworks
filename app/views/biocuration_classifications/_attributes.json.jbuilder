json.extract! biocuration_classification, :id, :biocuration_class_id, :biological_classification_object_id, :biological_classification_object_type, :position, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.partial! '/shared/data/all/metadata', object: biocuration_classification

json.biocuration_class do
  json.partial! '/controlled_vocabulary_terms/attributes', controlled_vocabulary_term: biocuration_classification.biocuration_class
end

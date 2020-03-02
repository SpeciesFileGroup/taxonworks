json.extract! biological_relationship_type, :id, :biological_property_id, :biological_relationship_id, :type, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.biological_property do
  json.partial! '/controlled_vocabulary_terms/attributes', controlled_vocabulary_term: biological_relationship_type.biological_property
end

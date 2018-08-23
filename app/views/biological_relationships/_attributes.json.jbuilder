json.extract! biological_relationship, :id, :name, :inverted_name, :is_transitive, :is_reflexive, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object:  biological_relationship

json.subject_biological_properties(biological_relationship.subject_biological_properties) do |p|
  json.partial! '/controlled_vocabulary_terms/attributes', controlled_vocabulary_term: p
end

json.object_biological_properties(biological_relationship.object_biological_properties) do |p|
  json.partial! '/controlled_vocabulary_terms/attributes', controlled_vocabulary_term: p
end


json.extract! biological_relationship, :id, :name, :inverted_name, :is_transitive, :is_reflexive, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object:  biological_relationship

json.subject_biological_relationship_types(biological_relationship.subject_biological_relationship_types) do |p|
  json.partial! '/biological_relationship_types/attributes', biological_relationship_type: p
end

json.object_biological_relationship_types(biological_relationship.object_biological_relationship_types) do |p|
  json.partial! '/biological_relationship_types/attributes', biological_relationship_type: p
end


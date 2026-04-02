json.extract! biological_relationship, :id, :name, :definition, :inverted_name, :is_transitive, :is_reflexive, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object:  biological_relationship

json.subject_biological_relationship_types(biological_relationship.subject_biological_relationship_types) do |p|
  json.partial! '/biological_relationship_types/api/v1/attributes', biological_relationship_type: p
end

json.object_biological_relationship_types(biological_relationship.object_biological_relationship_types) do |p|
  json.partial! '/biological_relationship_types/api/v1/attributes', biological_relationship_type: p
end

if extend_response_with('notes')
  json.notes biological_relationship.notes.each do |n|
    json.text n.text
  end
end

if extend_response_with('citations') && biological_relationship.has_citations?
  json.citations do
    json.array! biological_relationship.citations do |citation|
      json.partial! '/citations/api/v1/attributes', citation: citation, extensions: false
      json.source do
        json.partial! '/sources/api/v1/base_attributes', source: citation.source
      end
    end
  end
end

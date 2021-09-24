json.extract! biological_relationship_type, :id, :biological_property_id, :biological_relationship_id, :type, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

if extend_response_with('biological_property')
  json.biological_property do
    json.partial! '/shared/data/all/metadata', object: biological_relationship_type.biological_property, extensions: false
    # json.partial! '/controlled_vocabulary_terms/attributes', object: biological_relationship_type.biological_property
  end
end

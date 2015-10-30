json.array!(@biological_relationships) do |biological_relationship|
  json.extract! biological_relationship, :id, :name, :is_transitive, :is_reflexive, :created_by_id, :updated_by_id, :project_id
  json.url biological_relationship_url(biological_relationship, format: :json)
end

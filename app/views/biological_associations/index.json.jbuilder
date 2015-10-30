json.array!(@biological_associations) do |biological_association|
  json.extract! biological_association, :id, :biological_relationship_id, :biological_association_subject_id, :biological_association_subject_type, :biological_association_object_id, :biological_association_object_type, :created_by_id, :updated_by_id, :project_id
  json.url biological_association_url(biological_association, format: :json)
end

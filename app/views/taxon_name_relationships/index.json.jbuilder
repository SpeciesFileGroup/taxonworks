json.array!(@taxon_name_relationships) do |taxon_name_relationship|
  json.extract! taxon_name_relationship, :id, :subject_taxon_name_id, :object_taxon_name_id, :type, :created_by_id, :updated_by_id, :project_id, :source_id
  json.url taxon_name_relationship_url(taxon_name_relationship, format: :json)
end

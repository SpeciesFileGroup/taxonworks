json.extract! taxon_name_relationship, :id, :subject_taxon_name_id, :object_taxon_name_id, :type, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.object_tag taxon_name_relationship_tag(taxon_name_relationship.metamorphosize)
json.url taxon_name_relationship_url(taxon_name_relationship.metamorphosize, format: :json)


json.extract! taxon_name_relationship, :id, :subject_taxon_name_id, :object_taxon_name_id, :subject_status_tag, :object_status_tag, :type, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.inverse_assignment_method taxon_name_relationship.class.inverse_assignment_method
json.assignment_method taxon_name_relationship.class.assignment_method

json.subject_object_tag full_original_taxon_name_label(taxon_name_relationship.subject_taxon_name)
json.object_object_tag full_taxon_name_tag(taxon_name_relationship.object_taxon_name)

json.object_tag taxon_name_relationship_tag(taxon_name_relationship.metamorphosize)

json.url taxon_name_relationship_url(taxon_name_relationship.metamorphosize, format: :json)

json.partial! '/shared/data/all/metadata', object: taxon_name_relationship

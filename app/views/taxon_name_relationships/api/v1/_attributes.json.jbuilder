json.extract! taxon_name_relationship, :id, :subject_taxon_name_id, :object_taxon_name_id, :subject_status_tag, :object_status_tag, :type, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.inverse_assignment_method taxon_name_relationship.class.inverse_assignment_method
json.assignment_method taxon_name_relationship.class.assignment_method

json.subject_name taxon_name_name_string(taxon_name_relationship.subject_taxon_name)
json.object_name taxon_name_name_string(taxon_name_relationship.object_taxon_name)
json.global_id taxon_name_relationship.to_global_id.to_s

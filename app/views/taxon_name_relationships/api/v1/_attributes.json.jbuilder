json.extract! taxon_name_relationship, :id, :subject_taxon_name_id, :object_taxon_name_id, :subject_status_tag, :object_status_tag, :type, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.inverse_assignment_method taxon_name_relationship.class.inverse_assignment_method
json.assignment_method taxon_name_relationship.class.assignment_method

json.subject_name full_original_taxon_name_label(taxon_name_relationship.subject_taxon_name)
json.object_name label_for_taxon_name(taxon_name_relationship.object_taxon_name)
json.global_id taxon_name_relationship.to_global_id.to_s

if extend_response_with('notes')
  json.notes taxon_name_relationship.notes.each do |n|
    json.text n.text
  end
end

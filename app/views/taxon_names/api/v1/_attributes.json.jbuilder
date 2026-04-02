json.partial!('/taxon_names/api/v1/base_attributes', taxon_name:)
json.original_combination full_original_taxon_name_tag(taxon_name) # contains HTML

if extend_response_with('parent')
  if taxon_name.parent
    json.parent do |parent|
      json.extract! taxon_name.parent, :id
      json.partial! '/taxon_names/api/v1/base_attributes', taxon_name: taxon_name.parent
    end
  end
end

if extend_response_with('otus')
  if taxon_name.otus
    json.otus do
      json.array!(taxon_name.otus) do |otu|
        json.partial! '/otus/api/v1/attributes', otu:
      end
    end
  end
end

if extend_response_with('roles')
  if taxon_name.roles.any?
    json.taxon_name_author_roles do
      json.array! taxon_name.taxon_name_author_roles.each do |role|
        json.extract! role, :id, :position, :type
        json.partial! '/people/api/v1/brief', person: role.person
      end
    end
  end
end

if extend_response_with('ancestor_ids')
  json.ancestor_ids do
    json.array! taxon_name.ancestors.pluck(:id, :rank_class)
  end
end

if extend_response_with('children')
  if taxon_name.children.any?
    json.children do
      json.array! taxon_name.children.pluck(:id)
    end
  end
end

if extend_response_with('type_taxon_name_relationship')
  unless taxon_name.is_a?(Combination)
    json.type_taxon_name_relationship do
      if taxon_name.type_taxon_name_relationship
        json.partial! '/taxon_name_relationships/attributes', taxon_name_relationship: taxon_name.type_taxon_name_relationship
      end
    end
  end
end


if extend_response_with('original_citation')
	json.original_citation do
		json.partial! '/citations/api/v1/attributes', citation: taxon_name.origin_citation, extensions: false
	end
end

if extend_response_with('object_taxon_name_relationships')
	json.object_taxon_name_relationships TaxonNameRelationship.where(object_taxon_name_id: taxon_name.id) do |r|
		json.id r.id
		json.type r.type
		json.subject_id r.subject_taxon_name_id
		json.subject_taxon TaxonName.find(r.subject_taxon_name_id)
		json.object_id r.object_taxon_name_id
		json.object_taxon TaxonName.find(r.object_taxon_name_id)

		
		json.relationship_source Citation.where(citation_object_id: r.id).take
		json.subject_source Citation.where(citation_object_id: r.subject_taxon_name_id).take
		json.object_source Citation.where(citation_object_id: r.object_taxon_name_id).take


		
	end
end

if extend_response_with('subject_taxon_name_relationships')
	json.subject_taxon_name_relationships TaxonNameRelationship.where(subject_taxon_name_id: taxon_name.id) do |r|
		json.id r.id
		json.type r.type
		json.subject_id r.subject_taxon_name_id
		json.subject_taxon TaxonName.find(r.subject_taxon_name_id)
		json.object_id r.object_taxon_name_id
		json.object_taxon TaxonName.find(r.object_taxon_name_id)
		
		json.relationship_source Citation.where(citation_object_id: r.id).take
		json.subject_source Citation.where(citation_object_id: r.subject_taxon_name_id).take
		json.object_source Citation.where(citation_object_id: r.object_taxon_name_id).take

	end
end
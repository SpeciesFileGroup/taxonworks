json.extract! taxon_name, :id, :name, :parent_id,
  :cached, :cached_html, :feminine_name, :masculine_name,
  :nomenclatural_code,
  :neuter_name,
  :name,
  :etymology, :year_of_publication, :verbatim_author, :rank, :rank_string,
  :type, :created_by_id, :updated_by_id, :project_id,
  :cached_valid_taxon_name_id, :cached_original_combination, :cached_original_combination_html, :cached_author, :cached_author_year,
  :cached_secondary_homonym, :cached_primary_homonym, :cached_is_valid,
  :created_at, :updated_at, :verbatim_name

json.parent_name taxon_name.parent
json.original_combination full_original_taxon_name_label(taxon_name)
json.name_string label_for_taxon_name(taxon_name)
json.author taxon_name.author_string
json.year taxon_name.year_integer

json.original_source do
	json.id taxon_name.origin_citation
end

json.subject_relationships TaxonNameRelationship.where(subject_taxon_name_id: taxon_name.id) do |r|
	json.id r.id
	json.type r.type
	json.subject_id r.subject_taxon_name_id
	json.subject_taxon TaxonName.find(r.subject_taxon_name_id)
	json.object_id r.object_taxon_name_id
	json.object_taxon TaxonName.find(r.object_taxon_name_id)
	
	json.relationship_source Citation.where(citation_object_id: r.id).take
	
	subjectCit = TaxonName.find(r.subject_taxon_name_id)
	json.subject_source do
		json.id subjectCit.origin_citation
	end
	
	objectCit = TaxonName.find(r.object_taxon_name_id)
	json.object_source do
		json.id objectCit.origin_citation
	end
end

json.object_relationships TaxonNameRelationship.where(object_taxon_name_id: taxon_name.id) do |r|
	json.id r.id
	json.type r.type
	json.subject_id r.subject_taxon_name_id
	json.subject_taxon TaxonName.find(r.subject_taxon_name_id)
	json.object_id r.object_taxon_name_id
	json.object_taxon TaxonName.find(r.object_taxon_name_id)

	
	json.relationship_source Citation.where(citation_object_id: r.id).take
	
	subjectCit = TaxonName.find(r.subject_taxon_name_id)
	json.subject_source do
		json.id subjectCit.origin_citation
	end
	
	objectCit = TaxonName.find(r.object_taxon_name_id)
	json.object_source do
		json.id objectCit.origin_citation
	end
	
end



#http://127.0.0.1:3000/api/v1/taxon_names/818346/          #Elytrurus bicolor
#http://127.0.0.1:3000/api/v1/taxon_names/833139/
#http://127.0.0.1:3000/api/v1/taxon_names/1181570		#Paraptochus oregonus COMBINATION
#http://127.0.0.1:3000/api/v1/taxon_names/827503		#Paraptochus oregonus PROTONYM
#http://127.0.0.1:3000/api/v1/taxon_names/818346/inventory/summary?extend[]=taxon_name_relationships
json.extract! taxon_name, :id, :name, :parent_id,
  :cached, :cached_html, :feminine_name, :masculine_name,
  :nomenclatural_code,
  :neuter_name,
  :etymology, :year_of_publication, :verbatim_author, :rank, :rank_string,
  :type, :created_by_id, :updated_by_id, :project_id,
  :cached_valid_taxon_name_id, :cached_original_combination, :cached_original_combination_html, :cached_author, :cached_author_year,
  :cached_secondary_homonym, :cached_primary_homonym, :cached_is_valid,
  :created_at, :updated_at, :verbatim_name

json.year taxon_name.year_integer
json.name_string label_for_taxon_name(taxon_name)
json.original_combination full_original_taxon_name_label(taxon_name)






#http://127.0.0.1:3000/api/v1/taxon_names/818346/          #Elytrurus bicolor
#http://127.0.0.1:3000/api/v1/taxon_names/833139/
#http://127.0.0.1:3000/api/v1/taxon_names/1181570		#Paraptochus oregonus COMBINATION
#http://127.0.0.1:3000/api/v1/taxon_names/827503		#Paraptochus oregonus PROTONYM
#http://127.0.0.1:3000/api/v1/taxon_names/818346/inventory/summary?extend[]=taxon_name_relationships
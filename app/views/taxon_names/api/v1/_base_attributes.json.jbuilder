json.extract! taxon_name, :id, :name, :parent_id,
  :cached, :cached_html, :feminine_name, :masculine_name,
  :nomenclatural_code,
  :neuter_name,
  :etymology, :year_of_publication, :verbatim_author, :rank, :rank_string,
  :type, :created_by_id, :updated_by_id, :project_id,
  :cached_valid_taxon_name_id, :cached_original_combination, :cached_original_combination_html, :cached_author_year,
  :cached_secondary_homonym, :cached_primary_homonym,
  :created_at, :updated_at, :verbatim_name

json.year taxon_name.year_integer
json.name_string taxon_name_name_string(taxon_name)
json.original_combination full_original_taxon_name_string(taxon_name)

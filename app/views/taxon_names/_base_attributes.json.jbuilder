json.extract! taxon_name, :id, :name, :parent_id, :cached_html, :feminine_name, :masculine_name, :neuter_name, :cached_author_year, :etymology, :year_of_publication, :verbatim_author, :rank, :rank_string, :type, :created_by_id, :updated_by_id, :project_id, :cached_original_combination, :cached_secondary_homonym, :cached_primary_homonym, :created_at, :updated_at, :nomenclatural_code

json.partial! '/shared/data/all/metadata', object: taxon_name, klass: 'TaxonName'

json.original_combination full_original_taxon_name_tag(taxon_name)

json.extract! taxon_name, :id, :name, :parent_id, :cached_html, :cached_author_year, :year_of_publication, :verbatim_author, :rank, :rank_string, :type, :created_by_id, :updated_by_id, :project_id, :cached_valid_taxon_name_id, :cached_original_combination, :cached_secondary_homonym, :cached_primary_homonym, :created_at, :updated_at, :nomenclatural_code
json.object_tag taxon_name_tag(taxon_name)

json.partial! '/taxon_names/attributes', taxon_name: taxon_name

if taxon_name.parent
  json.parent do |parent|
    json.partial! '/taxon_names/attributes', taxon_name: taxon_name.parent
  end
end

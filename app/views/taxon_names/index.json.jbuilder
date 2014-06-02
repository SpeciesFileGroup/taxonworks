json.array!(@taxon_names) do |taxon_name|
  json.extract! taxon_name, :id, :name, :parent_id, :cached_name, :cached_author_year, :cached_higher_classification, :lft, :rgt, :source_id, :year_of_publication, :verbatim_author, :rank_class, :type, :created_by_id, :updated_by_id, :project_id, :cached_original_combination, :cached_secondary_homonym, :cached_primary_homonym, :cached_secondary_homonym_alt, :cached_primary_homonym_alt
  json.url taxon_name_url(taxon_name, format: :json)
end

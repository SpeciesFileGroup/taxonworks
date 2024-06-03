json.array!(@taxon_names) do |taxon_name|
  json.name label_for_taxon_name(taxon_name)
  json.original_name  full_original_taxon_name_label(taxon_name)
  json.source taxon_name.source&.cached
end

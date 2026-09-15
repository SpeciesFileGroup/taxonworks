json.array! @rows do |row|
  otu = row[:otu]
  match = row[:match]

  json.otu do
    json.extract! otu, :id, :name
    json.global_id otu.to_global_id.to_s
    json.object_label label_for_otu(otu)
  end

  json.match_string row[:match_string]
  json.matched match[:matched]
  json.ambiguous match[:ambiguous]
  json.taxon_name_id match[:taxon_name_id]

  json.candidates match[:candidates] do |taxon_name|
    json.extract! taxon_name, :id, :cached, :cached_html, :cached_author_year,
      :cached_is_valid, :cached_valid_taxon_name_id, :rank_class, :type
    json.global_id taxon_name.to_global_id.to_s
    json.object_label label_for_taxon_name(taxon_name)
  end
end

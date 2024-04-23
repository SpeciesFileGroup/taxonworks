json.array! @otu_metadata do |r|
  json.id r[:otu].id
  json.label otu_autocomplete_selected_tag(r[:otu]) # !! Note this is not used in TaxonPages
  json.label_html otu_extended_autocomplete_tag( r[:label_target])
  json.gid r[:otu].to_global_id.to_s
  json.otu_valid_id r[:otu_valid_id]
end

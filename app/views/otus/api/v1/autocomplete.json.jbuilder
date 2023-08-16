json.array! @otus do |o|
  json.id o.id
  json.label otu_autocomplete_selected_tag(o)
  json.label_html otu_tag(o)
  json.gid o.to_global_id.to_s
  json.otu_valid_id o.otu_valid_id #
  json.similarity o.sml_o_z
end

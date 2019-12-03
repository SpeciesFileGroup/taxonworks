json.reference_object @catalog.reference_object_global_id
json.reference_object_valid_taxon_name @catalog.reference_object_valid_taxon_name_global_id

json.metadata do
  json.count_items @catalog.items.count
  json.count_entries @catalog.entries.count

  json.entries do
    json.array! @catalog.entries do |ce|
      json.metadata ce.to_json
    end
  end
end

json.topics do
  json.array! @catalog.topics.collect{|t| {t.to_global_id.to_s => { name: t.name, css_color: t.css_color} }}
end

json.sources do
  json.array! @catalog.sources.collect{|s| { s.metamorphosize.to_global_id.to_s => { cached: s.cached, objects: @catalog.objects_for_source(s).collect{|o| o.object.to_global_id.to_s } }}}
end



json.items do
  json.array! @catalog.items_chronologically do |i|
    json.label_html send(i.html_helper, i)
    json.nomenclature_date i.nomenclature_date
    json.data_attributes i.data_attributes
    json.topics do
      json.array! i.topics.collect{|t| t.to_global_id.to_s}
    end
  end
end

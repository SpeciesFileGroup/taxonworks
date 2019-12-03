json.count_items @catalog.items.count
json.count_entries @catalog.entries.count

json.entries do
  json.array! @catalog.entries do |ce|
    json.metadata ce.to_json
  end
end

json.topics do
  json.array! @catalog.topics.collect{|t| {t.to_global_id.to_s => { name: t.name, css_color: t.css_color} }}
end

json.items do
  json.array! @catalog.items_chronologically do |i|
    json.data_attributes i.data_attributes

    json.topics do
      json.array! i.topics.collect{|t| t.to_global_id.to_s}
    end

    json.label_html send(i.html_helper, i)
    json.nomenclature_date i.nomenclature_date
  end
end

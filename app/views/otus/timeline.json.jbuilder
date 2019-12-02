json.count_items @catalog.items.count
json.count_entries @catalog.entries.count

json.entries do
  json.array! @catalog.entries do |ce|
    json.metadata ce.to_json
  end
end

json.items do
  json.array! @catalog.items_chronologically do |i|
    json.data_attributes i.data_attributes

    json.label_html send(i.html_helper, i)
    json.nomenclature_date i.nomenclature_date
  end
end

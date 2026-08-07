json.reference_object @collection_object.to_global_id.to_s

json.metadata do
  json.count_items @data.items.count
end

json.items do 
  json.array!(@data.ordered_by_date) do |item|
    json.type Catalog::CollectionObject::FILTER_MAP[item.type]
    json.event item.type.to_s.humanize
    json.date collection_object_catalog_date_range(item)
    json.derived_from item.object_class_name
    json.object collection_object_history_object_value(item) 
  end
end

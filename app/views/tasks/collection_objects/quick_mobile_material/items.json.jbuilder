ignored = TaskCapture::QuickMobileMaterial.ignored_for(@task_items.map(&:id))

json.array! @task_items do |item|
  co = item.composition_item_object
  catalog_number = co.identifiers.select { |i| i.type == 'Identifier::Local::CatalogNumber' }.min_by { |i| i.position.to_i }

  json.id item.id
  json.position item.position
  json.collection_object_id co.id
  json.global_id co.to_global_id.to_s
  json.buffered_collecting_event co.buffered_collecting_event
  json.ignored ignored[item.id] || []

  if catalog_number
    json.catalog_number do
      json.id catalog_number.id
      json.namespace_id catalog_number.namespace_id
      json.namespace_name catalog_number.namespace&.name
      json.identifier catalog_number.identifier
    end
  else
    json.catalog_number nil
  end

  json.depictions co.depictions.sort_by(&:id) do |depiction|
    json.id depiction.id
    json.image_id depiction.image_id
    json.thumb_url root_url + depiction.image.image_file.url(:thumb)[1..-1]
    json.medium_url root_url + depiction.image.image_file.url(:medium)[1..-1]
  end
end

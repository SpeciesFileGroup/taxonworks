json.extract! collection_object, :id, :total, :preparation_type_id, :collecting_event_id, :repository_id, :type, :buffered_collecting_event, :buffered_determinations,
      :buffered_other_labels, :ranged_lot_category_id, :deaccessioned_at, :deaccession_reason,
      :contained_in, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.partial! '/shared/data/all/metadata', object: collection_object 

json.images do
  json.array! collection_object.images do |image|
    json.id image.id
    json.url api_v1_image_url(image.to_param)
  end
end if collection_object.images

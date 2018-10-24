json.extract! pinboard_item, :id, :user_id, :pinned_object_type,
  :pinned_object_id, :position, :is_inserted, :is_cross_project,
  :inserted_count 

json.pinned_object_section pinboard_item.pinned_object_type.pluralize

json.partial! '/shared/data/all/metadata', object: pinboard_item 

json.pinned_object do
  json.partial! '/shared/data/all/metadata', object: pinboard_item.pinned_object
end


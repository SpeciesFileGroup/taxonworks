json.extract! collection_object, :id, :total, :preparation_type_id, :collecting_event_id, :repository_id, :type,
:buffered_collecting_event, :buffered_determinations, :buffered_other_labels, 
:ranged_lot_category_id, :accessioned_at, :deaccessioned_at, :deaccession_reason,
:created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.global_id collection_object.to_global_id.to_s

json.contained_in collection_object.contained_in

if collection_object.contained?
  json.container_id collection_object.container.id
end


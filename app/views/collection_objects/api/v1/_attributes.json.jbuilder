json.extract! collection_object, :id, :total, :preparation_type_id, :collecting_event_id, :repository_id, :type,
:buffered_collecting_event, :buffered_determinations, :buffered_other_labels,
:ranged_lot_category_id, :accessioned_at, :deaccessioned_at, :deaccession_reason,
:created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.global_id collection_object.to_global_id.to_s

if extend_response_with('container')
  if collection_object.contained?
    json.contained_in collection_object.contained_in
    json.container_id collection_object.container.id
  end
end

if extend_response_with('dwc_fields')
  json.dwc do
    json.merge!(collection_object.dwc_occurrence_attributes.select{|k,v| !v.blank?} )
  end
end

if extend_response_with('type_material')
  json.type_material collection_object.type_materials do |tm|
    json.extract! tm, :type_type
    json.partial! '/shared/data/all/metadata', object: tm
  end
end

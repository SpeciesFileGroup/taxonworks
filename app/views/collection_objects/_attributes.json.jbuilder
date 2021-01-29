json.extract! collection_object, :id, :total, :repository_id, :preparation_type_id, :collecting_event_id
json.extract! collection_object.get_dwc_occurrence,  :catalogNumber, :scientificName, :lifeStage, :sex, :country, :stateProvince, :verbatimLocality
json.extract! collection_object, :buffered_collecting_event, :buffered_determinations, :buffered_other_labels, 
  :accessioned_at, :deaccessioned_at, :deaccession_reason,
  :created_by_id, :updated_by_id, :created_at, :updated_at
json.object_tag collection_object_tag(collection_object) # TODO: optimize this
json.global_id collection_object.to_global_id.to_s




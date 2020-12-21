json.array! @collection_objects do |co|
  json.extract! co, :id, :total
  json.extract! co.get_dwc_occurrence,  :catalogNumber, :scientificName, :lifeStage, :sex, :country, :stateProvince, :verbatimLocality
  json.extract! co, :buffered_collecting_event, :buffered_determinations, :buffered_other_labels, 
    :accessioned_at, :deaccessioned_at, :deaccession_reason,
    :created_by_id, :updated_by_id, :created_at, :updated_at
  json.global_id co.to_global_id.to_s
end




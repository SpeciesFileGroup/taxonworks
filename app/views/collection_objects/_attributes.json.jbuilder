json.extract! collection_object, :id, :total, :repository_id, :current_repository_id, :preparation_type_id, :collecting_event_id,
:buffered_collecting_event, :buffered_determinations, :buffered_other_labels,
:accessioned_at, :deaccessioned_at, :deaccession_reason,
:created_by_id, :updated_by_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: collection_object

if extend_response_with('dwc_fields')
  json.dwc do
    json.merge!(collection_object.get_dwc_occurrence_attributes.select{|k,v| !v.blank?} )
  end
end

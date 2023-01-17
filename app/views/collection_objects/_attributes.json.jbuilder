json.extract! collection_object, :id, :total, :repository_id, :current_repository_id, :preparation_type_id, :collecting_event_id,
:buffered_collecting_event, :buffered_determinations, :buffered_other_labels,
:accessioned_at, :deaccessioned_at, :deaccession_reason,
:created_by_id, :updated_by_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: collection_object

if extend_response_with('dwc_fields')
  json.dwc do
    json.merge!(collection_object.dwc_occurrence_attributes.select{|k,v| !v.blank?} )
  end
end

if extend_response_with('taxon_determination_images')
  json.determination_images do
    json.array! sqed_depiction_buffered_determination_images(collection_object)
  end
end

if extend_response_with('identifiers')
  json.identifiers do
    json.array! collection_object.identifiers.pluck(:cached)
  end
end

if extend_response_with('taxon_determinations')
  json.taxon_determinations do |ct|
    json.array! collection_object.taxon_determinations, partial: '/taxon_determinations/attributes', as: :taxon_determination
  end
end

# TODO: partial with object
if extend_response_with('data_attributes')
  json.data_attributes do |ct|
    json.array! collection_object.data_attributes, partial: '/data_attributes/attributes', as: :data_attribute, extensions: false
  end
end

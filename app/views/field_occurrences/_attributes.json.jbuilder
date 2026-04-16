json.extract! field_occurrence, :id, :total, :collecting_event_id, :is_absent, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: field_occurrence 


# json.url field_occurrence_url(field_occurrence, format: :json)

if extend_response_with('collecting_event') && field_occurrence.collecting_event.present?
  json.collecting_event do
    json.partial! '/collecting_events/attributes', collecting_event: field_occurrence.collecting_event, extensions: false
  end
end

if extend_response_with('identifiers')
  json.identifiers do
    json.array! field_occurrence.identifiers.each do |i|
      json.cached i.cached
    end
  end
end

if extend_response_with('taxon_determinations')
  json.taxon_determinations do |ct|
    json.array! field_occurrence.taxon_determinations, partial: '/taxon_determinations/attributes', as: :taxon_determination, extensions: false
  end
end

# TODO: partial with object
if extend_response_with('data_attributes')
  json.data_attributes do |ct|
    json.array! field_occurrence.data_attributes, partial: '/data_attributes/attributes', as: :data_attribute, extensions: false
  end
end


if extend_response_with('dwc_occurrence')
  json.dwc_occurrence do
    json.merge!(field_occurrence.dwc_occurrence&.attributes&.select{|k,v| v.present?} )
  end
end

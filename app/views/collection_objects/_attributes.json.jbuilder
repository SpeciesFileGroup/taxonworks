json.extract! collection_object, *CollectionObject.core_attributes

json.partial! '/shared/data/all/metadata', object: collection_object

if extend_response_with('dwc_occurrence')
  json.dwc_occurrence do
    json.merge!(collection_object.dwc_occurrence_attributes.select{|k,v| v.present?} )
  end
end

if extend_response_with('collecting_event')  && collection_object.collecting_event.present?
  json.collecting_event do
    json.partial! '/collecting_events/attributes', collecting_event: collection_object.collecting_event, extensions: false
  end
end

if extend_response_with('repository') && collection_object.repository.present?
  json.repository do
    json.partial! '/repositories/attributes', collecting_event: collection_object.repository, extensions: false
  end
end

if extend_response_with('current_repository') && collection_object.current_repository.present?
  json.current_repository do
    json.partial! '/repositories/attributes', collecting_event: collection_object.current_repository, extensions: false
  end
end

if extend_response_with('identifiers')
  json.identifiers do
    json.array! collection_object.identifiers do |i|
      json.cached i.cached
    end
  end
end

if extend_response_with('taxon_determinations')
  json.taxon_determinations do |ct|
    json.array! collection_object.taxon_determinations, partial: '/taxon_determinations/attributes', as: :taxon_determination, extensions: false
  end
end

# TODO: partial with object
if extend_response_with('data_attributes')
  json.data_attributes do |ct|
    json.array! collection_object.data_attributes, partial: '/data_attributes/attributes', as: :data_attribute, extensions: false
  end
end

# TODO: Rename
if extend_response_with('taxon_determination_images')
  json.determination_images do
    json.array! sqed_depiction_buffered_determination_images(collection_object)
  end
end

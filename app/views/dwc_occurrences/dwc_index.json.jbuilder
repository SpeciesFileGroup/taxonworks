json.column_headers do
  json.array! ['collection_object_id', 'dwc_occurrence_id'] + CollectionObject::DwcExtensions::DWC_OCCURRENCE_MAP.keys.sort
end

json.data do
  json.array! @objects
end




json.column_headers do
  json.array! @klass.dwc_attribute_vector_names
end

json.data do
  json.array! @objects
end

json.column_headers do
  json.array! @headers
end

json.data do
  json.array! @objects
end

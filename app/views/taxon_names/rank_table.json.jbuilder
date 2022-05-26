json.column_headers  do
  json.array! @query.column_headers
end

json.data do
  json.array!(@query.all) do |r|
    json.array! (r.values)
  end
end

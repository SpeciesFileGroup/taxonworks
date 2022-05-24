json.column_headers  do
  json.array! @q.column_headers
end

json.data do
  json.array!(@q.all) do |r|
    json.array! (r.values)
  end
end

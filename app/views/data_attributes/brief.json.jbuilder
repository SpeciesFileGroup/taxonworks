json.index do
  json.merge! @columns
end

json.data do
  json.merge! @data.to_a
end

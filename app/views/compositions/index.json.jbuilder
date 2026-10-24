json.array!(@compositions) do |composition|
  json.partial! 'attributes', composition: composition
end

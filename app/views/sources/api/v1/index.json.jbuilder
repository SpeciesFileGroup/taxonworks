json.array!(@sources) do |source|
  json.partial! '/sources/api/v1/attributes', source: source
end

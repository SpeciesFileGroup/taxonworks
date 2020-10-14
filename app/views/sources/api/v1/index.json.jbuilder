json.array!(@sources) do |source|
  json.partial! '/sources/api/attributes', source: source
end

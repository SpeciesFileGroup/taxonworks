json.array!(@sources) do |source|
  json.partial! '/sources/attributes', source: source
end

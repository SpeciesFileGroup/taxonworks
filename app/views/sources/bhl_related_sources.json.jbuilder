json.bhl_source do
  if @bhl_source
    json.partial! '/sources/base_attributes', source: @bhl_source
  end
end

json.taxonworks_sources do
  json.array!(@taxonworks_sources) do |source|
    json.partial! '/sources/attributes', source: source
  end
end
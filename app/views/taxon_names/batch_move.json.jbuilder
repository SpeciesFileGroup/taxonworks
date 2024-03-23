json.moved do
  json.array!(@result[:moved]) do |taxon_name|
    json.partial! '/taxon_names/attributes', taxon_name: 
  end
end

json.unmoved do
  json.array!(@result[:unmoved]) do |taxon_name|
    json.partial! '/taxon_names/attributes', taxon_name: 
  end
end


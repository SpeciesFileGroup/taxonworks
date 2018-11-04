json.array!(@taxon_names) do |taxon_name|
  json.partial! '/taxon_names/attributes', taxon_name: taxon_name
end

json.array!(@taxon_names) do |taxon_name|
  json.partial! '/taxon_names/api/v1/base_attributes', taxon_name: taxon_name
end

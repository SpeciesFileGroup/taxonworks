json.array!(@taxon_name_classifications) do |taxon_name_classification|
  json.partial! '/taxon_name_classifications/api/v1/attributes', taxon_name_classification: taxon_name_classification
end

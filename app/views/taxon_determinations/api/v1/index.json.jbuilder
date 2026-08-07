json.array!(@taxon_determinations) do |taxon_determination|
  json.partial! '/taxon_determinations/api/v1/attributes', taxon_determination: taxon_determination
end

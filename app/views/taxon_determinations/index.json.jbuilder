json.array!(@taxon_determinations) do |taxon_determination|
  json.partial! '/taxon_determinations/attributes', taxon_determination: taxon_determination
end

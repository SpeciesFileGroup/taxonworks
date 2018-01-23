json.partial! '/taxon_names/base_attributes', taxon_name: combination

json.protonyms do
  combination.combination_relationships.each do |r|
    json.set! r.rank_name do
      json.partial! '/taxon_names/attributes', taxon_name: r.subject_taxon_name 
    end
  end
end

json.is_current_placement combination.is_current_placement?

# TODO: move to shared
if combination.origin_citation
  json.origin_citation do
    json.partial! '/citations/attributes', citation: combination.origin_citation
  end
end


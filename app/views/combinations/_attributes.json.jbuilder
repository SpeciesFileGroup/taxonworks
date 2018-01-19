json.partial! '/taxon_names/base_attributes', taxon_name: combination

json.protonyms do
  combination.protonyms.each do |p|
    json.set! p.rank_class.rank_name do
      json.partial! '/taxon_names/attributes', taxon_name: p 
    end
  end
end

# TODO: move to shared
if combination.origin_citation
  json.origin_citation do
    json.partial! '/citations/attributes', citation: combination.origin_citation
  end
end


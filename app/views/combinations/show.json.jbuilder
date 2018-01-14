@combination.protonyms.each do |p|
  json.set! p.rank_class.rank_name do
    json.partial! '/taxon_names/attributes', taxon_name: p 
  end
end

# TODO: move to shared
if @combination.origin_citation
  json.origin_citation do
    json.partial! '/citations/attributes', citation: combination.origin_citation
  end
end


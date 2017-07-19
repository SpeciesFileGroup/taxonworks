json.partial! '/taxon_names/base_attributes', taxon_name: taxon_name

if taxon_name.parent
  json.parent do |parent|
    json.partial! '/taxon_names/base_attributes', taxon_name: taxon_name.parent
  end
end

if taxon_name.origin_citation
  json.origin_citation do
    json.partial! '/citations/attributes', citation: taxon_name.origin_citation
  end
end


json.partial! '/taxon_names/api/v1/attributes', taxon_name: taxon_name

if taxon_name.origin_citation
  json.original_citation do
    json.partial! '/citations/api/v1/attributes', citation: taxon_name.origin_citation, extensions: false
  end
end

# Duplicates origin_citation ^ when present, that's okay.
if extend_response_with('base_citations')
  json.base_citations taxon_name.citations do |c|
    json.partial! '/citations/api/v1/attributes', citation: c, extensions: false
  end
end

json.taxon_name_classifications taxon_name.taxon_name_classifications do |r|
  json.partial! '/taxon_name_classifications/api/v1/attributes', taxon_name_classification: r, extensions: false
end

json.object_taxon_name_relationships taxon_name.related_taxon_name_relationships do |r|
  json.id r.id
  json.type r.type

  if extend_response_with('relationship_citations')
    json.citations r.citations do |c|
      json.partial! '/citations/api/v1/attributes', citation: c, extensions: false
    end
  end

  json.subject_taxon_name do
    json.partial! '/taxon_names/api/v1/base_attributes', taxon_name: r.subject_taxon_name, extensions: false

    if extend_response_with('related_citations')
      json.citations r.subject_taxon_name.citations do |c|
        json.partial! '/citations/api/v1/attributes', citation: c, extensions: false
      end
    end
  end
end

json.subject_taxon_name_relationships taxon_name.taxon_name_relationships do |r|
  json.id r.id
  json.type r.type

  if extend_response_with('relationship_citations')
    json.citations r.citations do |c|
      json.partial! '/citations/api/v1/attributes', citation: c, extensions: false
    end
  end

  json.object_taxon_name do
    json.partial! '/taxon_names/api/v1/base_attributes', taxon_name: r.object_taxon_name, extensions: false

    if extend_response_with('related_citations')
      json.citations r.object_taxon_name.citations do |c|
        json.partial! '/citations/api/v1/attributes', citation: c, extensions: false
      end
    end
  end
end

json.extract! @taxon_name, :id
json.parent_id @taxon_name.parent_id
json.is_valid @taxon_name.cached_is_valid
json.name @taxon_name.name
json.full_name taxon_name_label(@taxon_name)

json.nomenclatural_code @taxon_name.nomenclatural_code
json.short_status taxon_name_short_status_label(@taxon_name)
json.status taxon_name_status_label(@taxon_name)
json.rank @taxon_name.rank

if !@taxon_name.cached_is_valid && !@taxon_name.is_ambiguously_invalid?
  json.valid_name do
    json.id @taxon_name.cached_valid_taxon_name_id
    json.valid_name @taxon_name.valid_taxon_name.name
    json.valid_full_name taxon_name_label(@taxon_name.valid_taxon_name)
  end
end

if extend_response_with('taxon_name_classifications') 
  json.taxon_name_classifications( @taxon_name.taxon_name_classifications) do |cl|
    json.type cl.type
    json.nomen_uri cl.class.nomen_uri
    json.label label_for_taxon_name_classification(cl)
    json.status cl.classification_label
    json.id cl.id
    json.global_id cl.to_global_id.to_s
  end
end

if extend_response_with('taxon_name_relationships') 
  json.subject_taxon_name_relationships( @taxon_name.taxon_name_relationships.where(type: TAXON_NAME_RELATIONSHIP_NAMES_INVALID)) do |r|
    json.type r.type
    json.nomen_uri r.class.nomen_uri
    json.label label_for_taxon_name_relationship(r)
    json.related_name label_for_taxon_name(r.object_taxon_name)
    json.status r.subject_status
    json.id r.id
    json.global_id r.to_global_id.to_s
  end
end

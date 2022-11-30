json.extract! @taxon_name, :id, :parent_id, :name
json.is_valid @taxon_name.cached_is_valid
json.full_name label_for_taxon_name(@taxon_name)
json.full_name_tag full_taxon_name_tag(@taxon_name)

json.nomenclatural_code @taxon_name.nomenclatural_code
json.short_status taxon_name_short_status_label(@taxon_name)
json.status taxon_name_status_label(@taxon_name)
json.rank @taxon_name.rank
json.rank_string @taxon_name.rank_string
json.author @taxon_name.author_string
json.year @taxon_name.cached_nomenclature_date&.year
json.pages @taxon_name.origin_citation&.pages
json.original_citation @taxon_name.source&.cached

if extend_response_with('name_elements')
  if @taxon_name.type == 'Protonym'
    json.elements do
      json.name do
        h = @taxon_name.full_name_hash
        json.merge! h.keys.inject({}){|hsh,k| hsh.merge(k => [h[k]].flatten.compact.join(' '))}
      end
      json.original_combination do
        h = @taxon_name.original_combination_elements
        json.merge! h.keys.inject({}){|hsh,k| hsh.merge(k => [h[k]].flatten.compact.join(' '))}
      end
    end
  end
end

if !@taxon_name.cached_is_valid && !@taxon_name.is_ambiguously_invalid?
  json.valid_name do
    json.id @taxon_name.cached_valid_taxon_name_id
    json.valid_name @taxon_name.valid_taxon_name.name
    json.valid_full_name label_for_taxon_name(@taxon_name.valid_taxon_name)

    json.author @taxon_name.valid_taxon_name.author_string
    json.year @taxon_name.valid_taxon_name.cached_nomenclature_date&.year
    json.pages @taxon_name.valid_taxon_name.origin_citation&.pages
    json.original_citation @taxon_name.valid_taxon_name.source&.cached

    # By definition it's a Protonym
    if extend_response_with('name_elements')
      h = @taxon_name.valid_taxon_name.full_name_hash
      json.merge! h.keys.inject({}){|hsh,k| hsh.merge(k => [h[k]].flatten.compact.join(' '))}
      json.author @taxon_name.valid_taxon_name.author_string
      json.year @taxon_name.valid_taxon_name.cached_nomenclature_date&.year
      json.original_citation @taxon_name.valid_taxon_name.source&.cached
    end
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

    json.pages cl.origin_citation&.pages
    json.original_citation cl.source&.cached
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

    json.pages r.origin_citation&.pages
    json.original_citation r.source&.cached
  end
end

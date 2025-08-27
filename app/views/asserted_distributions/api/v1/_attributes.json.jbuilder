json.extract! asserted_distribution, :id,
  :asserted_distribution_object_id, :asserted_distribution_object_type,
  :asserted_distribution_shape_id, :asserted_distribution_shape_type,
  :project_id, :created_by_id, :updated_by_id, :is_absent,
  :created_at, :updated_at

json.origin_citation_source_id asserted_distribution.origin_citation_source_id
json.global_id asserted_distribution.to_global_id.to_s

json.citations(asserted_distribution.citations) do |citation|
  json.id citation.id.to_s
  json.global_id citation.to_global_id.to_s
  json.pages citation.pages

  json.source do
    json.name citation.source.cached
    json.global_id citation.source.to_global_id.to_s
  end
end
json.asserted_distribution_object do
  klass = asserted_distribution.asserted_distribution_object_type
  json.type klass

  k = klass.underscore
  json.partial! "/#{k.pluralize}/api/v1/attributes",
    { k.to_sym => asserted_distribution.asserted_distribution_object }

  #Additional data.
  case klass
  when 'Otu'
    json.taxon_name asserted_distribution.asserted_distribution_object.taxon_name&.cached
  end
end

json.asserted_distribution_shape do
  json.type asserted_distribution.asserted_distribution_shape_type

  if asserted_distribution.asserted_distribution_shape_type == 'GeographicArea'
    json.partial! '/geographic_areas/api/v1/attributes',
      geographic_area: asserted_distribution.asserted_distribution_shape
  elsif asserted_distribution.asserted_distribution_shape_type == 'Gazetteer'
    json.partial! '/gazetteers/api/v1/attributes',
      gazetteer: asserted_distribution.asserted_distribution_shape
  end
end

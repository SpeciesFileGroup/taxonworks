
json.extract! asserted_distribution, :id,
  :asserted_distribution_object_id, :asserted_distribution_object_type,
  :asserted_distribution_shape_type, :asserted_distribution_shape_id,
  :project_id, :created_by_id, :updated_by_id, :is_absent, :created_at,
  :updated_at

json.partial! '/shared/data/all/metadata', object: asserted_distribution

if extend_response_with('asserted_distribution_object')
  json.asserted_distribution_object do
    klass = asserted_distribution.asserted_distribution_object_type.underscore
    json.partial! "/#{klass.pluralize}/attributes",
      {klass.to_sym => asserted_distribution.asserted_distribution_object}
  end
end

if extend_response_with('taxonomy')
  json.taxonomy do
    json.merge! asserted_distribution.otu.taxonomy
  end
end

if extend_response_with('asserted_distribution_shape')
  json.asserted_distribution_shape do
    if asserted_distribution.asserted_distribution_shape_type == 'GeographicArea'
      json.partial! '/geographic_areas/attributes',
        geographic_area: asserted_distribution.asserted_distribution_shape
    elsif asserted_distribution.asserted_distribution_shape_type == 'Gazetteer'
      json.partial! '/gazetteers/attributes',
        gazetteer: asserted_distribution.asserted_distribution_shape
    end
  end
end

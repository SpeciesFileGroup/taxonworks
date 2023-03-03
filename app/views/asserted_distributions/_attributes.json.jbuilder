json.extract! asserted_distribution, :id, :otu_id, :geographic_area_id, :project_id, :created_by_id, :updated_by_id, :is_absent, :created_at, :updated_at
json.partial! '/shared/data/all/metadata', object: asserted_distribution

if extend_response_with('otu')
  json.otu do
    json.partial! '/shared/data/all/metadata', object: asserted_distribution.otu, extensions: false
  end
end

if extend_response_with('taxonomy')
  json.taxonomy do
    json.merge! asserted_distribution.otu.taxonomy
  end
end

if extend_response_with('geographic_area')
  json.geographic_area do
    json.partial! '/geographic_areas/attributes', geographic_area: asserted_distribution.geographic_area
  end
end

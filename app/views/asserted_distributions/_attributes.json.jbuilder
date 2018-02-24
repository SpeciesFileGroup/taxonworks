json.extract! asserted_distribution, :id, :otu_id, :geographic_area_id, :project_id, :created_by_id, :updated_by_id, :is_absent, :created_at, :updated_at

json.origin_citation_source_id asserted_distribution.origin_citation_source_id

json.partial! '/shared/data/all/metadata', object: asserted_distribution, klass: 'AssertedDistribution'

json.citations do
  json.array! asserted_distribution.citations.reload, partial: '/citations/attributes', as: :citation
end

json.otu do
  json.partial! '/otus/attributes', otu: asserted_distribution.otu
end

json.geographic_area do
  json.partial! '/geographic_areas/attributes', geographic_area: asserted_distribution.geographic_area
end

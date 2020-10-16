json.extract! asserted_distribution, :id, :otu_id, :geographic_area_id, :project_id, :created_by_id, :updated_by_id, :is_absent, :created_at, :updated_at

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

json.otu do
  json.name asserted_distribution.otu.name
  json.taxon_name_id asserted_distribution.otu.taxon_name_id
  json.taxon_name asserted_distribution.otu.taxon_name.cached
  json.global_id asserted_distribution.otu.to_global_id.to_s
end

json.geographic_area do
  json.partial! '/geographic_areas/api/v1/attributes', geographic_area: asserted_distribution.geographic_area
end

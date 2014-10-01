json.array!(@asserted_distributions) do |asserted_distribution|
  json.extract! asserted_distribution, :id, :otu_id, :geographic_area_id, :source_id, :project_id, :created_by_id, :updated_by_id, :is_absent
  json.url asserted_distribution_url(asserted_distribution, format: :json)
end

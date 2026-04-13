if extend_response_with('otu')
  if extend_response_with('taxonomy')
    @asserted_distributions = @asserted_distributions.includes(otu: :taxon_name)
  else
    @asserted_distributions = @asserted_distributions.includes(:otu)
  end
end

if extend_response_with('asserted_distribution_shape')
  @asserted_distributions =
    @asserted_distributions.includes(:asserted_distribution_shape)
end

if extend_response_with('citations')
  @asserted_distributions =
    @asserted_distributions.includes(:citations)
end

json.array!(@asserted_distributions) do |asserted_distribution|
  json.partial! '/asserted_distributions/attributes', asserted_distribution: asserted_distribution
end

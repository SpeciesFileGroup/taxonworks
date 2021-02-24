json.array!(@asserted_distributions) do |asserted_distribution|
  json.partial! '/asserted_distributions/api/v1/attributes', asserted_distribution: asserted_distribution
end

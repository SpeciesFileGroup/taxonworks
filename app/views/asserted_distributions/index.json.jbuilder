json.array!(@asserted_distributions) do |asserted_distribution|
  json.partial! '/asserted_distributions/attributes', asserted_distribution: asserted_distribution
end

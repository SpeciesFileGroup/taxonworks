json.moved do
  json.array!(@result[:moved]) do |asserted_distribution|
    json.partial! '/asserted_distributions/attributes', asserted_distribution: 
  end
end

json.unmoved do
  json.array!(@result[:unmoved]) do |asserted_distribution|
    json.partial! '/asserted_distributions/attributes', asserted_distribution: 
  end
end


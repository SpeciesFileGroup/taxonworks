json.array!(@biological_associations_graphs) do |biological_associations_graph|
  json.partial! '/biological_associations_graphs/api/v1/attributes', biological_associations_graph:
end

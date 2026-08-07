json.array!(@biological_associations_graphs) do |bag|
  json.partial! '/biological_associations_graphs/attributes', biological_associations_graph: bag
end

@biological_associations_graphs.each_key do |group|
  json.set!(group) do
    json.array! @biological_associations_graphs[group] do |b|
      json.partial! '/biological_associations_graphs/attributes', biological_associations_graph: b
    end
  end
end

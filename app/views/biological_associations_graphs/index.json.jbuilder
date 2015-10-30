json.array!(@biological_associations_graphs) do |biological_associations_graph|
  json.extract! biological_associations_graph, :id, :created_by_id, :updated_by_id, :project_id, :name, :source_id
  json.url biological_associations_graph_url(biological_associations_graph, format: :json)
end

json.extract! biological_associations_graph, :id, :created_by_id, :updated_by_id, :project_id, :name
json.partial! '/shared/data/all/metadata', object: biological_associations_graph

if extend_response_with('biological_associations_biological_associations_graphs')
  json.biological_associations_biological_associations_graphs do
    json.array!  biological_associations_graph.biological_associations_biological_associations_graphs.each do |babag|
     json.id babag.id
     json.biological_association_id babag.biological_association_id
     if extend_response_with('biological_associations')
        json.partial! '/shared/data/all/metadata', object: babag.biological_association, extend: false
     end
    end
  end
end
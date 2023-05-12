json.array! @biological_associations_graphs.each do |t|
  json.id t.id
  json.label biological_associations_graph_tag(t)
  json.label_html biological_associations_graph_tag(t) 
  json.gid t.to_global_id.to_s

  json.response_values do 
    if params[:method]
      json.set! params[:method], t.id
    end
  end 
end

module BiologicalAssociationsGraphsHelper

  def biological_associations_graph_tag(biological_associations_graph)
    return nil if biological_associations_graph.nil?
    biological_associations_graph.name ||'Nameless graph. id: ' + biological_associations_graph.to_param 
  end

  def biological_associations_graph_link(biological_associations_graph)
    return nil if biological_associations_graph.nil?
    a = biological_associations_graph_tag(biological_associations_graph)
    link_to(a.html_safe, biological_associations_graph)
  end

end

module BiologicalAssociationsGraphsHelper

  def biological_associations_graph_tag(biological_associations_graph)
    return nil if biological_associations_graph.nil?
    biological_associations_graph.name
  end

  def biological_associations_graph_link(biological_associations_graph)
    return nil if biological_associations_graph.nil?
    link_to(biological_associations_graph_tag(biological_associations_graph).html_safe, biological_associations_graph)
  end

end

json.origin_relationships @origin_relationships

nodes = @nodes.map do |n|
  klass = n.class.base_class.name

  n.as_json.merge({
    object_type: klass,
    object_label: anatomical_part_graph_label_for_related_object(n)
  })
end

json.nodes nodes

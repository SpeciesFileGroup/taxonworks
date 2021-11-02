module GraphHelper


  def object_graph(object)
    return nil if object.nil?

    case object.class.base_class.name
    when 'CollectionObject'
      collection_object_graph(object).to_json
    when 'CollectingEvent'
      collecting_event_graph(object).to_json
    else
      g = Export::Graph.new( object: object )
      g.to_json
    end
  end

  def collecting_event_graph(collecting_event, graph: nil, target: nil, collection_objects: true)
    c = collecting_event
    return nil if c.nil?

    g = initialize_graph(graph, c, target)

    if collection_objects
      c.collection_objects.each do |o|
        collection_object_graph(o, graph: g, target: c, collecting_event: false)
      end
    end

    c.collectors.each do |p|
      g.add(p,c)
    end
    c
    g
  end

  # @return Export::Graph
  def collection_object_graph(collection_object, graph: nil, target:  nil, collecting_event: true)
    c = collection_object
    return nil if c.nil?

    g = initialize_graph(graph, c, target)

    collecting_event_graph(c.collecting_event, graph: g, target: c, collection_objects: false)

    if r = c.repository
      g.add(r, c)
    end

    c.biocuration_classes.each do |b|
      g.add(b, c)
    end

    c.observations.each do |o|
      g.add(o, c)
    end

    c.taxon_determinations.each do |d|
      g.add(d, c)
      g.add(d.otu, d)

      d.determiners.each do |p|
        g.add(p, d)
      end

      if d.otu.taxon_name
        taxon_name_graph(d.otu.taxon_name, graph: g, target: d.otu)
      end
    end

    c.all_biological_associations.each do |b|
      g.add_node(b.biological_association_subject)
      g.add_node(b.biological_association_object)
      g.add_node(b.biological_relationship)

      g.add_edge(b.biological_relationship, b.biological_association_subject)
      g.add_edge(b.biological_relationship, b.biological_association_object)
    end

    g
  end

  def taxon_name_graph(taxon_name, graph: nil, target: nil)
    t = taxon_name
    return nil if t.nil?

    g = initialize_graph(graph, t, target)

    t.taxon_name_authors.each do |p|
      g.add(p, t)
    end
    taxon_name_graph(t.parent, graph: g, target: t)

    g
  end

  def initialize_graph(graph, object, target)
    g = graph
    if g.nil?
      g = Export::Graph.new(object: object)
    else
      g.add(object, target)
    end
    g
  end

# def add_graph_node(object, node_link = nil, nodes, edges)
#   nodes.push graph_node(object, node_link)

#   object.citations.each do |c|
#     nodes.push graph_node(c)
#     edges.push graph_edge(object, c)

#     nodes.push graph_node(c.source)
#     edges.push graph_edge(c, c.source)

#     if c.source.is_bibtex?
#       c.source.source_authors.each do |a|
#         nodes.push graph_node(a)
#         edges.push graph_edge(c.source, a)
#       end
#     end

#   end
# end

end

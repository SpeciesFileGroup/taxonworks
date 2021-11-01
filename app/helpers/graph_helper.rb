module GraphHelper


  def object_graph(object)
    return nil if object.nil?

    case object.class.base_class.name
    when 'CollectionObject'
      collection_object_graph(object)
    else
      g = Export::Graph.new( object: object ) 
      g.to_json
    end 
  end

  def collection_object_graph(collection_object, graph = nil, target = nil)
    g = graph
    g ||= Export::Graph.new(object: collection_object)

    g.to_json
  end

=begin



    nodes = [
      graph_node(collection_object),
      graph_node(collection_object.collecting_event)
    ]

    edges = [
      graph_edge(collection_object, collection_object.collecting_event, 'collecting event') 
    ]

    if collection_object.collecting_event
      collection_object.collecting_event.collectors.each do |c|
        edges.push graph_edge(collection_object.collecting_event, c)
        nodes.push graph_node(c)
      end     

      collection_object.collecting_event.identifiers.each do |i|
        nodes.push graph_node(i)
        edges.push graph_edge(collection_object.collecting_event, i)
      end
    end

    collection_object.taxon_determinations.each do |t|
      add_object_to_graph(t, collection_object, nodes, edges)
      add_object_to_graph(t.otu, t, nodes, edges)

      nomenclature_graph(nodes, edges, t.otu.taxon_name, t.otu)

      t.determiners.each do |d|
        nodes.push graph_node(d)
        edges.push graph_edge(t,d)

        d.identifiers.each do |i|
          nodes.push graph_node(i)
          edges.push graph_edge(d, i)
        end
      end

      if r = collection_object.repository
        nodes.push graph_node(r)
        edges.push graph_edge(collection_object,r)

        r.identifiers.each do |i|
          add_object_to_graph(i, r, nodes, edges)
        end       
      end
    end

    collection_object.observations.each do |o|
      add_object_to_graph(o, collection_object, nodes, edges)

      o.identifiers.each do |i|
        add_object_to_graph(i, o)
      end       
    end

    collection_object.identifiers.each do |i|
      add_object_to_graph(i, collection_object, nodes, edges)
    end

    collection_object.all_biological_associations.each do |b|
      nodes.push graph_node(b.biological_association_subject)
      nodes.push graph_node(b.biological_association_object)
      nodes.push graph_node(b.biological_relationship)

      edges.push graph_edge(b.biological_relationship, b.biological_association_subject)
      edges.push graph_edge(b.biological_relationship, b.biological_association_object)
    end

    collection_object.biocuration_classes.each do |b|
      add_object_to_graph(b, collection_object, nodes, edges)
    end


  end
=end


  def nomenclature_graph(nodes, edges, taxon_name, target)
    return if taxon_name.nil?

    nodes.push graph_node(taxon_name)
    edges.push graph_edge(taxon_name, target)

    taxon_name.taxon_name_authors.each do |a|
      nodes.push graph_node(a)
      edges.push graph_edge(taxon_name, a)

      a.identifiers.each do |i|
        nodes.push graph_node(i)
        edges.push graph_edge(a, i)
      end
    end

    nomenclature_graph(nodes, edges, taxon_name.parent, taxon_name)
  end

  def add_object_to_graph(object, object_origin, nodes, edges)
    nodes.push graph_node(object)
    edges.push graph_edge(object_origin, object)
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


  def graph_node(object, node_link = nil)
    return nil if object.nil?
    b = object.class.base_class.name
    h = {
      id: object.to_global_id.to_s,
      name: label_for(object) || object.class.base_class.name,
      color: NODE_COLORS[b] || '#000000'
    }

    h[:shape] = NODE_SHAPES[b] if !NODE_SHAPES[b].nil?
    h[:link] = node_link unless node_link.blank?
    h
  end

  def graph_edge(start_object, end_object, edge_label = nil, edge_link = nil)
    return nil if start_object.nil? || end_object.nil?
    h = {
      start_id: start_object.to_global_id.to_s,
      end_id: end_object.to_global_id.to_s
    }

    h[:label] = edge_label unless edge_label.blank?
    h[:link] = edge_link unless edge_link.blank?
    h
  end

  end

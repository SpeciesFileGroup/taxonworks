module GraphHelper

  def object_graph(object)
    case object.class.base_class.name
    when 'CollectionObject'
      collection_object_graph(object)
    else
      { nodes: [ graph_node(object) ],
        edges: [ ]
      }
    end 
  end

  def collection_object_graph(collection_object)
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
      nodes.push graph_node(t)
      edges.push graph_edge(collection_object, t)

      nodes.push graph_node(t.otu)
      edges.push graph_edge(t, t.otu)

      nomenclature_graph(nodes, edges, t.otu.taxon_name, t.otu)

      t.determiners.each do |d|
        nodes.push graph_node(d)
        edges.push graph_edge(t,d)
      end

    end

    collection_object.identifiers.each do |i|
      edges.push graph_edge(collection_object, i)
      nodes.push graph_node(i)
    end

    return { 
      nodes: nodes.compact.uniq,
      edges: edges.compact.uniq
    }
  end

  def nomenclature_graph(nodes, edges, taxon_name, target)
    return if taxon_name.nil?

    nodes.push graph_node(taxon_name)
    edges.push graph_edge(taxon_name, target)

    nomenclature_graph(nodes, edges, taxon_name.parent, taxon_name)
  end

  def graph_node(object, node_link = nil)
    return nil if object.nil?
    h = {
      id: object.to_global_id.to_s,
      name: label_for(object)
    }

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

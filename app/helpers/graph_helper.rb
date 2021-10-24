module GraphHelper

  # const colors = [, , , , , , , , , , ]

  NODE_COLORS = {
    'Person' => '#009688',
    'CollectionObject' => '#2196F3',
    'TaxonName' => '#E91E63',
    'CollectingEvent' => '#7E57C2',
    'TaxonDetermination' => '#FF9800',
    'Identifier' => '#EF6C00',
    'Otu' =>'#4CAF50',
    'User' => '#F44336',
    'ControlledVocabularyTerm' => '#CDDC39',
    'BiologicalRelationship' => '#9C27B0'
  }

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

        d.identifiers.each do |i|
          nodes.push graph_node(i)
          edges.push graph_edge(d, i)
        end
    
      end
    end

    collection_object.identifiers.each do |i|
      edges.push graph_edge(collection_object, i)
      nodes.push graph_node(i)
    end

    collection_object.all_biological_associations.each do |b|
      nodes.push graph_node(b.biological_association_subject)
      nodes.push graph_node(b.biological_association_object)
      nodes.push graph_node(b.biological_relationship)

      edges.push graph_edge(b.biological_relationship, b.biological_association_subject)
      edges.push graph_edge(b.biological_relationship, b.biological_association_object)
    end

    collection_object.biocuration_classes.each do |b|
      nodes.push graph_node(b)
      edges.push graph_edge(collection_object, b) # subject
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


  def graph_node(object, node_link = nil)
    return nil if object.nil?
    h = {
      id: object.to_global_id.to_s,
      name: label_for(object) || object.class.base_class.name,
      color: NODE_COLORS[object.class.base_class.name] || '#000000'
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

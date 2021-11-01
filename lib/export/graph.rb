class Export::Graph

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
    'BiologicalRelationship' => '#9C27B0',
    'Repository' => '#009688',
    'Observation' => '#CDDC39',
    'Citation' => '#009688',
  }

  NODE_SHAPES = {
    'Person' => 'person', 
    'CollectionObject' => 'circle', 
    'TaxonName' => 'square', 
    'CollectingEvent' => 'circle', 
    'TaxonDetermination' => nil,
    'Identifier' => 'triangle',
    'Otu' => 'hexagon', 
    'User' => 'person', 
    'ControlledVocabularyTerm' => nil,
    'BiologicalRelationship' => nil ,
    'Observation' => 'square',
    'Citation' => 'square',
    'Repository' => 'circle'
  }

  RENDERABLE_ANNOTATIONS = [

  ]

  attr_accessor :nodes
  attr_accessor :edges

  attr_accessor :draw_annotations 

  # @params object [An AR record, nil]
  #   the "base" of the object, if rooted
  def initialize(object: nil, annotations_to_draw: RENDERABLE_ANNOTATIONS )
    @draw_annotations = annotations_to_draw
    @nodes = []
    @edges = []

    add(object) if !object.nil?
  end

  def nodes
    @nodes.compact.uniq
  end

  def edges
    @edges.compact.uniq
  end

  def to_json
    return { 
      nodes: nodes,
      edges: edges
    }
  end

  def add(object, object_origin = nil)
    @nodes.push graph_node(object)
    @edges.push graph_edge(object_origin, object)
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
      name:  ApplicationController.helpers.label_for(object) || object.class.base_class.name,
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

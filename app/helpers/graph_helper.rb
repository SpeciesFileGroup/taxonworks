module GraphHelper


  def object_graph(object)
    return nil if object.nil?

    case object.class.base_class.name
    when 'CollectionObject'
      collection_object_graph(object, collecting_event: true, taxon_determinations: true, biological_associations: true).to_json
    when 'CollectingEvent'
      collecting_event_graph(object, collection_objects: true).to_json
    when 'TaxonName'
      taxon_name_graph(object, children: true, parents: true, otus: true, synonymy: true).to_json
    when 'Otu'
      otu_graph(object, collection_objects: true, taxon_name: true, synonymy: true, biological_associations: true).to_json
    when 'TaxonDetermination'
      taxon_determination_graph(object, collection_object: true, taxon_names: true).to_json
    else
      g = Export::Graph.new( object: object )
      g.to_json
    end
  end

  def collecting_event_graph(collecting_event, graph: nil, target: nil, collection_objects: false)
    c = collecting_event
    return nil if c.nil?

    g = initialize_graph(graph, c, target)

    if collection_objects
      c.collection_objects.each do |o|
        collection_object_graph(o, graph: g, target: c, taxon_determinations: true)
      end
    end

    c.collectors.each do |p|
      g.add(p,c)
    end

    c.georeferences.each do |r|
      g.add(r,c)
      r.georeferencers.each do |p|
        g.add(p,r)
      end
    end

    g
  end

  def otu_graph(otu, graph: nil, target: nil, collection_objects: false, taxon_name: true, synonymy: false, biological_associations: true )
    o = otu
    return nil if o.nil?
    g = initialize_graph(graph, o, target)

    if taxon_name
      taxon_name_graph(o.taxon_name, graph: g, target: o, synonymy: synonymy, parents: true)
    end

    if collection_objects
      o.collection_objects.each do |co|
        collection_object_graph(co, graph: g, target: o, collecting_event: true)
      end
    end

    if biological_associations
      o.all_biological_associations.each do |b|
        g.add_node(b.biological_association_subject)
        g.add_node(b.biological_association_object)
        g.add_node(b.biological_relationship)

        g.add_edge(b.biological_relationship, b.biological_association_subject)
        g.add_edge(b.biological_relationship, b.biological_association_object)
      end
    end

    g
  end

  def taxon_determination_graph(taxon_determination, graph: nil, target: nil, collection_object: false, taxon_names: false)
    td = taxon_determination
    return nil if td.nil?
    g = initialize_graph(graph, td, target)

    g.add(td.otu, td)

    if collection_object
      g.add(td.biological_collection_object, td)
    end

    if taxon_names
      if td.otu.taxon_name
        taxon_name_graph(td.otu.taxon_name, graph: g, target: td.otu, parents: true)
      end
    end

    td.determiners.each do |p|
      g.add(p, td)
    end

    g
  end

  # @return Export::Graph
  def collection_object_graph(collection_object, graph: nil, target: nil, collecting_event: false, taxon_determinations: false, biological_associations: false)
    c = collection_object
    return nil if c.nil?

    g = initialize_graph(graph, c, target)

    collecting_event_graph(c.collecting_event, graph: g, target: c)

    if r = c.repository
      g.add(r, c)
    end

    c.biocuration_classes.each do |b|
      g.add(b, c)
    end

    c.observations.each do |o|
      g.add(o, c)
    end

    if taxon_determinations
      c.taxon_determinations.each do |d|
        taxon_determination_graph(d, graph: g, target: c, taxon_names: true)
      end
    end

    if biological_associations
      c.all_biological_associations.each do |b|
        g.add_node(b.biological_association_subject)
        g.add_node(b.biological_association_object)
        g.add_node(b.biological_relationship)

        g.add_edge(b.biological_relationship, b.biological_association_subject)
        g.add_edge(b.biological_relationship, b.biological_association_object)
      end
    end

    g
  end

  def taxon_name_graph(taxon_name, graph: nil, target: nil, synonymy: false, children: false, otus: false, parents: false)
    t = taxon_name
    return nil if t.nil?

    g = initialize_graph(graph, t, target)

    t.taxon_name_authors.each do |p|
      g.add(p, t)
    end

    if children
      t.children.each do |n|
        taxon_name_graph(n, target: t, graph: g)
      end
    end

    if synonymy
      t.synonyms.each do |n|
        taxon_name_graph(n, target: t, graph: g)
      end
    end

    if otus
      t.otus.each do |o|
        otu_graph(o, target: t, graph: g)
      end
    end

    if parents
      taxon_name_graph(t.parent, graph: g, target: t, parents: parents)
    end

    g
  end

  private

  def initialize_graph(graph, object, target)
    g = graph
    if g.nil?
      g = Export::Graph.new(object: object)
    else
      g.add(object, target)
    end
    g
  end

end

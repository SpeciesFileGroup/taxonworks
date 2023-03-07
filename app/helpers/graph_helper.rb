module GraphHelper

  def object_graph(object)
    return nil if object.nil?

    case object.class.base_class.name
    when 'CollectionObject'
      collection_object_graph(object, collecting_event: true, taxon_determinations: true, biological_associations: true, images: true).to_json
    when 'CollectingEvent'
      collecting_event_graph(object, collection_objects: true).to_json
    when 'TaxonName'
      taxon_name_graph(object, children: true, parents: true, otus: true, synonymy: true).to_json
    when 'Otu'
      otu_graph(object, collection_objects: true, taxon_name: true, synonymy: true, biological_associations: true, asserted_distributions: true).to_json
    when 'TaxonDetermination'
      taxon_determination_graph(object, collection_object: true, taxon_names: true).to_json
    when 'Person'
      person_graph(object).to_json
    when 'Citation'
      citation_graph(object, source: true, citation_object: true, topics: true).to_json
    when 'Source'
      source_graph(object, citations: true, authors: true, editors: true).to_json
    when 'Image'
      image_graph(object, citations: true, depictions: true).to_json
    else
      g = Export::Graph.new( object: object )
      g.to_json
    end
  end

  def source_graph(source, graph: nil, target: nil, citations: false, authors: false, editors: false)
    s = source
    return nil if s.nil?

    g = initialize_graph(graph, nil, nil)

    # We can't auto-cite, so .add can not be used
    g.add_node(s, citations: false, identifiers: true)
    g.add_edge(target, s)

    if authors && s.respond_to?(:authors)
      s.authors.each do |p|
        g.add(p, s)
      end
    end

    if editors && s.respond_to?(:editors)
      s.editors.each do |p|
        g.add(p, s)
      end
    end

    if citations
      s.citations.where(project_id: sessions_current_project_id).each do |c|
        citation_graph(c, graph: g, target: s, citation_object: true, topics: true)
      end
    end

    g
  end

  def image_graph(image, graph: nil, target: nil, depictions: false, citations: false, copyright_holders: true)
    i = image
    return nil if i.nil?

    g = initialize_graph(graph, i, target)

    if depictions
      i.depictions.each do |d|
        depiction_graph(d, graph: g, target: i)
      end
    end

    if citations
      i.citations.where(project_id: sessions_current_project_id).each do |c|
        citation_graph(c, graph: g, target: i, citation_object: true, topics: true)
      end
    end

    g
  end

  def depiction_graph(depiction, graph: nil, target: nil)
    d = depiction
    return nil if d.nil?

    g = initialize_graph(graph, d, target)

    o = d.depiction_object
    g.add_node(o)
    g.add_edge(d, o)

    g
  end


  def citation_graph(citation, graph: nil, target: nil, source: false, citation_object: false, topics: true)
    c = citation
    return nil if c.nil?

    g = initialize_graph(graph, c, target)

    if source
      source_graph(c.source, graph: g, target: c, authors: true, editors: true)
    end

    if citation_object
      g.add_node(c.citation_object, citations: false, identifiers: true)
      g.add_edge(c, c.citation_object)
    end

    if topics
      c.topics.each do |t|
        g.add(t, c)
      end
    end
    g
  end

  def person_graph(person, graph: nil, target: nil)
    p = person
    return nil if p.nil?

    g = initialize_graph(graph, p, target)

    # TODO: Loop has_many
    [:authored_sources, :edited_sources, :human_sources].each do |m|
      p.send(m).each do |o|
        g.add(o, p)
      end
    end

    [ :collecting_events, :taxon_determinations, :authored_taxon_names, :georeferences, :collection_objects, :dwc_occurrences].each do |m|
      p.send(m).where(project_id: sessions_current_project_id).each do |o|
        g.add(o,p)
      end
    end

    g
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

  def otu_graph(otu, graph: nil, target: nil, collection_objects: false, taxon_name: true, synonymy: false, biological_associations: true, asserted_distributions: true )
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

    if asserted_distributions 
      o.asserted_distributions.each do |a|

        g.add_node(a)
        g.add_node(a.geographic_area)

        g.add_edge(a, a.geographic_area)
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
  def collection_object_graph(collection_object, graph: nil, target: nil, collecting_event: false, taxon_determinations: false, biological_associations: false, images: false)
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

    if images
      c.images.each do |i|
        image_graph(i, graph: g, target: c)
      end
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

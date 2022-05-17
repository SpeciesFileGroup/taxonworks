module CollectionObjectsHelper

  # Return [String, nil]
  #   a descriptor including the identifier and determination
  def collection_object_tag(collection_object)
    return nil if collection_object.nil?
    a = [
      collection_object_deaccession_tag(collection_object),
      collection_object_identifier_tag(collection_object),
      taxon_determination_tag(collection_object.taxon_determinations.order(:position).first)
    ].compact

    if a.empty?
      a << [
        collection_object.buffered_collecting_event,
        collection_object.buffered_determinations,
        collection_object.buffered_other_labels
      ].compact
    end

    a << "[#{collection_object.type[(0..2)].capitalize}]"

    a.join('&nbsp;').html_safe
  end

  def collection_object_link(collection_object)
    return nil if collection_object.nil?
    link_to(collection_object_tag(collection_object).html_safe, collection_object.metamorphosize)
  end

  def collection_object_radial_tag(collection_object)
    content_tag(:span, '', data: { 'global-id' => collection_object.to_global_id.to_s, 'collection-object-radial' => 'true'})
  end

  def label_for_collection_object(collection_object)
    return nil if collection_object.nil?
    [ 'CollectionObject ' + collection_object.id.to_s,
      identifier_list_labels(collection_object)
    ].compact.join('; ')
  end

  def collection_object_autocomplete_tag(collection_object)
    return nil if collection_object.nil?
    [collection_object_identifier_tag(collection_object),
     collection_object_taxon_determination_tag(collection_object)
    ].join(' ').html_safe
  end

  def collection_objects_search_form
    render('/collection_objects/quick_search_form')
  end

  def verify_accessions_task_link(collection_object)
    priority = [collection_object.container, collection_object.identifiers.first, collection_object ].compact.first
    link_to('Verify', verify_accessions_task_path(by: priority.metamorphosize.class.name.tableize.singularize.to_sym, id: priority.to_param))
  end

  def collection_object_identifier_tag(collection_object)
    return nil if collection_object.nil?
    t, i = collection_object_visualized_identifier(collection_object)

    return content_tag(:span, i, class: [
      :feedback,
      'feedback-thin',
      (t == :collection_object ? 'feedback-primary' : 'feedback-warning')
    ]) if i
    content_tag(:span, 'no identifier assigned', class: [:feedback, 'feedback-thin', 'feedback-warning'])
  end

  def collection_object_deaccession_tag(collection_object)
    return nil if collection_object.nil? || (collection_object.deaccession_reason.blank? && collection_object.deaccessioned_at.nil?)
    msg = ['DEACCESSIONED"', collection_object.deaccession_reason, collection_object.deaccessioned_at&.year].compact.join(' - ')
    content_tag(:span, msg, class: [
      :feedback,
      'feedback-thin',
      'feedback-danger'
    ]).html_safe
  end

  # @return [Array [Identifier, String (type)], nil]
  #    also checks virtual container for identifier by proxy
  def collection_object_visualized_identifier(collection_object)
    return nil if collection_object.nil?
    # Get the Identifier::Local::Catalog number on collection_object, or immediate containing Container
    i = collection_object.preferred_catalog_number # see delegation in collection_object.rb

    # Get some other identifier on collection_object
    i ||= collection_object.identifiers.order(:position)&.first
    return  [:collection_object, identifier_tag(i)] if i

    # Get some other identifier on container
    j = collection_object&.container&.identifiers&.first
    return [:container, identifier_tag(j)] if j
    nil
  end

  def collection_object_taxon_determination_tag(collection_object)
    return nil if collection_object.nil?
    i = taxon_determination_tag(collection_object.taxon_determinations.order(:position).first)
    return content_tag(:span, i, class: [:feedback, 'feedback-thin', 'feedback-secondary']) if i
    nil
  end

  # TODO: Isolate into own helper
  # TODO: syncronize with class methods
  def dwc_occurrence_table_header_tag
    content_tag(:tr, CollectionObject::DwcExtensions::DWC_OCCURRENCE_MAP.keys.collect{|k| content_tag(:th, k)}.join.html_safe, class: [:error])
  end

  def dwc_occurrence_table_body_tag(collection_objects)
    collection_objects.collect do |c|
      dwc_occurrence_table_row_stub(c).html_safe
    end.join.html_safe
  end

  def dwc_table(collection_objects)
    content_tag(:table) do
      dwc_occurrence_table_header_tag +
        dwc_occurrence_table_body_tag(collection_objects)
    end
  end

  def dwc_occurrence_table_row_stub(collection_object)
    r = collection_object.dwc_occurrence
    if r
      dwc_occurrence_table_row_tag(r)
    else
      id = collection_object.to_param
      content_tag(:tr, nil, id: "dwc_row_stub_#{id}", data: {'collection-object-id': id}, class: 'dwc_row_stub' )
    end
  end

  def dwc_occurrence_table_row_tag(dwc_occurrence)
    o = metamorphosize_if(dwc_occurrence.dwc_occurrence_object)
    content_tag(:tr, class: :contextMenuCells) do
      [CollectionObject::DwcExtensions::DWC_OCCURRENCE_MAP.keys.collect{|k| content_tag(:td, dwc_occurrence.send(k))}.join,
       fancy_show_tag(o),
       fancy_edit_tag(o)
      ].join.html_safe
    end
  end

  # @return [link_to]
  #    this may not work for all identifier types, i.e. those with identifiers like `123.34` or `3434.33X` may not increment correctly
  def collection_object_browse_previous_by_identifier(collection_object)
    return nil if collection_object.nil?
    o = collection_object.previous_by_identifier
    return content_tag(:div, 'None', 'class' => 'navigation-item disable') if o.nil?
    link_text = content_tag(:span, 'Previous by id', 'class' => 'small-icon icon-left', 'data-icon' => 'arrow-left')
    link_to(link_text, browse_collection_objects_task_path(collection_object_id: o.id), data: {
      arrow: :previous,
      'no-turbolinks' => 'true',
      help: 'Sorts by identifier type, namespace, then an conversion of identifier into integer.  Will not work for all identifier types.'},
      class: 'navigation-item')
  end

  # @return [link_to]
  #   this may not work for all identifier types, i.e. those with identifiers like `123.34` or `3434.33X` may not increment correctly
  def collection_object_browse_next_by_identifier(collection_object)
    return nil if collection_object.nil?
    o = collection_object.next_by_identifier
    return content_tag(:div, 'None', 'class' => 'navigation-item disable') if o.nil?
    link_text = content_tag(:span, 'Next by id', 'class' => 'small-icon icon-right', 'data-icon' => 'arrow-right')
    link_to(link_text, browse_collection_objects_task_path(collection_object_id: o.id),
            data: {arrow: :next,
                   'no-turbolinks' => 'false',
                   help: 'Sorts by identifier type, namespace, then an conversion of identifier into integer.  Will not work for all identifier types.'}, class:'navigation-item')
  end

  def collection_object_metadata_badge(collection_object)
    return nil if collection_object.nil?
    o = collection_object

    layout = Waxy::Geometry::Layout.new(
      Waxy::Geometry::Orientation::LAYOUT_POINTY,
      Waxy::Geometry::Point.new(14,14), # size
      Waxy::Geometry::Point.new(14,14), # start
      0 # padding
    )

    s = [
      (o.identifiers.any? ? 1 : 0),
      (o.taxon_determinations.any? ? 1 : 0),
      (o.collecting_event&.map_center.nil? ? 0 : 1),
      (o.collecting_event_id ? 1 : 0),
      (o.buffered_determinations.blank? ? 0 : 1),
      (o.buffered_collecting_event.blank? ? 0 : 1),
    ]

    a = Waxy::Meta.new
    a.size = s
    a.stroke = 'grey'
    a.link_title = "#{o.id.to_s} created #{time_ago_in_words(o.created_at)} ago by #{user_tag(o.creator)}"

    c = Waxy::Render::Svg::Canvas.new(28, 28)
    c.body << Waxy::Render::Svg.rectangle(layout, [a], 0)
    c.to_svg
  end

  # Perhaps a /lib/catalog method
  # @return Hash
  def collection_object_count_by_classification(scope = nil)
    return [] if scope.nil?
    specimen_data = {}
    lot_data = {}

    total_index = {}

    scope.each do |n|
      a = ::Queries::CollectionObject::Filter.new(project_id: sessions_current_project_id, ancestor_id: n.id, collection_object_type: 'Specimen').all
      b = ::Queries::CollectionObject::Filter.new(project_id: sessions_current_project_id, ancestor_id: n.id, collection_object_type: 'Lot').all

      ts = CollectionObject.where(id: a).calculate(:sum, :total)
      tl = CollectionObject.where(id: b).calculate(:sum, :total)

      if (ts > 0) || (tl > 0)
        lot_data[n.cached] = tl
        specimen_data[n.cached] = ts
        total_index[n.cached] = ts + tl
      end

    end

    # We only need to sort 1 pile!
    specimen_data = specimen_data.sort{|a,b| total_index[b[0]] <=> total_index[a[0]] }.to_h

    return {
      total_index: total_index,
      data: [
        { name: 'Specimen', data: specimen_data},
        { name: 'Lot', data: lot_data}
      ]
    }
  end

  # Perhaps a /lib/catalog method
  # @return Hash
  def collection_object_preparation_by_classification(scope = nil)
    return [] if scope.nil?
    data = {}
    no_data = {}

    preparations = ::PreparationType.joins(:collection_objects).where(collection_objects: {project_id: sessions_current_project_id}).distinct

    i = 0
    scope.each do |n|

      j = []

      a = ::Queries::CollectionObject::Filter.new(
        project_id: sessions_current_project_id,
        ancestor_id: n.id
      )

      # Yes a custom query could do this much faster
      preparations.each do |p|
        a.preparation_type_id = p.id
        t = CollectionObject.where(id: a.all).calculate(:sum, :total)
        if t > 0
          j.push [p.name, t]
          i += 1
        end
      end

      if j.empty?
        # There are no data at all, don't query for Missing
        no_data[n.id] = n.cached
      else
        a.preparation_type_id = nil
        a.preparation_type = false
        w = CollectionObject.where(id: a.all).calculate(:sum, :total)
        if w > 0
          j.push ['Missing', w]
        end

        data[n.cached] = j
      end
    end

    return {
      labels: preparations.collect{|p| p.name} + ['Missing'],
      data: data,
      no_data: no_data
    }

  end
end

module CollectionObjects::CatalogHelper

  def collection_object_history_table(data)
    tag.table( class: [:full_width]) do
      tag.tr do
        tag.th('Event') +
          tag.th('Date') +
          tag.th('Derived from') +
          tag.th('Object')
      end +
      data.ordered_by_date.collect{|d| collection_object_history_row(d)}.join.html_safe
    end
  end

  def collection_object_history_row(item)
    tag.tr( class: Catalog::CollectionObject::FILTER_MAP[item.type]) do
      tag.td( item.type.to_s.humanize ) +
        tag.td( collection_object_catalog_date_range(item) ) +
        tag.td( item.object_class_name ) +
        collection_object_history_object_value(item)
    end
  end

  def collection_object_history_object_value(item)
    case item.object_class_name
    when 'Tag'
      tag.td( controlled_vocabulary_term_tag(item.object.keyword) )
    when 'Depiction'
      tag.td( image_link(item.object.image))
    else
      tag.td( object_link(item.object))
    end
  end

  def collection_object_catalog_date_range(item)
    d = [ item.start_date, item.end_date].compact.collect{|t| t.strftime('%F')}.join('-')
    d.empty? ? tag.em('not provided') : d
  end

end

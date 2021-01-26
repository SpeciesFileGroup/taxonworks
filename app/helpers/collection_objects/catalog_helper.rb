module CollectionObjects::CatalogHelper

  def collection_object_history_table(data)
    content_tag(:table, class: [:full_width]) do
      content_tag(:tr) do
        content_tag(:th, 'Event') +
          content_tag(:th, 'Date') +
          content_tag(:th, 'Derived from') + 
          content_tag(:th, 'Object') 
      end +
      data.ordered_by_date.collect{|d| collection_object_history_row(d)}.join.html_safe 
    end
  end

  def collection_object_history_row(item)
    content_tag(:tr, class: ::Catalog::CollectionObject::FILTER_MAP[item.type]) do 
      content_tag(:td, item.type.to_s.humanize ) +
        content_tag(:td, collection_object_catalog_date_range(item) ) +
        content_tag(:td, item.object_class_name ) + 
        collection_object_history_object_value(item) 
    end
  end

  def collection_object_history_object_value(item)
    case item.object_class_name
    when 'Tag'
      content_tag(:td, controlled_vocabulary_term_tag(item.object.keyword) )
    when 'Depiction'
      content_tag(:td, image_link(item.object.image))
    else
      content_tag(:td, object_link(item.object))
    end
  end

  def collection_object_catalog_date_range(item)
    d = [ item.start_date, item.end_date].compact.collect{|t| t.strftime('%F')}.join('-')
    d.empty? ? content_tag(:em,'not provided') : d
  end

end

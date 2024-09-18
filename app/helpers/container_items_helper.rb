module ContainerItemsHelper

  def container_item_tag(container_item)
    return nil if container_item.nil?
    object_tag(container_item.contained_object)
  end

  def container_item_link(container_item)
    return nil if container_item.nil?
    link_to(container_item_tag(container_item).html_safe, container_item)
  end

  def container_items_search_form
    render('/container_items/quick_search_form')
  end

  # TODO: make generic
  def container_item_container_label(container_item)
    return nil if container_item.nil?
    o = container_item.contained_object
    case container_item.contained_object_type
    when 'CollectionObject'
      label_for_collection_object_container(o)
    when 'Extract'
      label_for_extract_container(o)
    when 'Container'
      label_for_container_container(o)
    else
      "NO CONTAINER LABEL FOR  A #{ container_item.container_object_type }, poke your developers!"
    end
  end


end

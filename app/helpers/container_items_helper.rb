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

end

module ContainerItemsHelper

  def container_item_tag(container_item)
    return nil if container_item.nil?
    object_tag(container_item.contained_object) 
  end
end

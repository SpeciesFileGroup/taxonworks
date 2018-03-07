module ContainersHelper

  def container_tag(container)
    return nil if container.nil?
    container.name ? container.name : (container.class.name + ' [' + container.to_param + ']').html_safe
  end

  def container_link(container)
    return nil if container.nil?
    link_to(container_tag(container.metamorphosize).html_safe, container.metamorphosize)
  end

  def container_parent_tag(container)
    return nil if container.container_item.nil?
    return nil if container.container_item.parent.nil?
    container_tag(container.container_item.parent.contained_object)
  end

  def container_parent_link(container)
    return nil if container.container_item.nil?
    return nil if container.container_item.parent.nil?
    link_to(container.container_item.parent.contained_object)
  end


  def containers_search_form
    render('/containers/quick_search_form')
  end

  def container_collection_item_count(container)
    return content_tag(:em, 'no container provided') if container.blank?
    v = container.all_contained_objects.count
    v == 0 ? 'empty' : v
  end

  # @return [String, nil]
  #    a string representation of the containers location, includes disposition of the containers if provided
  def container_location(object)
    return nil if !object.containable?
    parts = [] 
    object.enclosing_containers.each do |c| 
      s = c.name.blank? ? c.class.class_name : c.name
      s += " [#{c.disposition}]" if !c.disposition.blank? 
      parts.push s 
    end
    parts.join('; ') 
  end

  # TODO: move content to containers/_card
  def draw_container_tag(container)
    return nil if container.nil?

    content_tag(:div, class: :draw_container) do
      content_tag(:div) do
        container_tag(container)
      end +

      content_tag(:div) do
        content_tag(:ul) do
          container.container_items.collect { |a| content_tag(:li, container_item_tag(a)) }
        end
      end
    end
  end

  def add_or_move_to_container_link(object)
    link_to( (object.contained? ? 'Move to another' : 'Add to' ) + ' container', containerize_collection_object_path(object) )
  end

end

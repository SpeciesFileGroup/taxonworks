module ContainersHelper

  def container_tag(container)
    return nil if container.nil?
    container.name? ? container.name : (container.class.name + " [" + container.to_param + "]").html_safe
  end

  def container_link(container)
    return nil if container.nil?
    link_to(container_tag(container.metamorphosize).html_safe, container.metamorphosize)
  end

  def containers_search_form
    render('/containers/quick_search_form')
  end

end

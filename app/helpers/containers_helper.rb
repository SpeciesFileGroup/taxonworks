module ContainersHelper

  def container_tag(container)
    return nil if container.nil?
    container.name? ? container.name : (container.class.name + " [" + container.to_param + "]").html_safe
  end

  def container_link(container)
    return nil if container.nil?
    link_to(taxon_works_container_tag(container).html_safe, container)
  end

  def containers_search_form
    render('/containers/quick_search_form')
  end

end

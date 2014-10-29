module ContainersHelper

  def container_tag(container)
    return nil if container.nil?
    container.name? ? container.name : (container.class.name + " [" + container.to_param + "]").html_safe
  end

end

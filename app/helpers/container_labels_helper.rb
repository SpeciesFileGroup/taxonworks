module ContainerLabelsHelper

  # @param [container] !
  def container_labels_tag(container)
    return nil if container.nil?
    container.container_labels.collect{|a| a.label}.join('<br><br>').html_safe
  end
end

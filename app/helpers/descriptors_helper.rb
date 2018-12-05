module DescriptorsHelper

  def descriptor_tag(descriptor)
    return nil if descriptor.nil?
    descriptor.name
  end

  def descriptors_search_form
    render('/descriptors/quick_search_form')
  end

  def descriptor_link(descriptor)
    return nil if descriptor.nil?
    link_to(descriptor_tag(descriptor).html_safe, descriptor.metamorphosize)
  end

  def descriptor_matrix_column_link(descriptor)
    z = [descriptor.short_name, descriptor.name].compact.first
    link_to(z, new_descriptor_task_path(descriptor.metamorphosize), data: {help: descriptor.name})
  end

end

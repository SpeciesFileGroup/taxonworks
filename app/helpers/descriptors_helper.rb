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

end

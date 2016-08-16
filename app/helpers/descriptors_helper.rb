module DescriptorsHelper
  def descriptor_tag(descriptor)
    return nil if descriptor.nil?
    descriptor.id.to_s
  end

  def descriptors_search_form
    render('/descriptors/quick_search_form')
  end

  def descriptor_link(descriptor)
    return nil if descriptor.nil?
    link_to(descriptor_tag(descriptor), descriptor)
  end
end

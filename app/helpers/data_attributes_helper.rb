module DataAttributesHelper

  def add_data_attribute_link(object: object, attribute: nil)
    link_to('Add data attribute', new_data_attribute_path(
      data_attribute: { 
          data_attribute_object_type: object.class.base_class.name,
          data_attribute_object_id: object.id})) if object.has_data_attributes?
  end

  def data_attribute_tag(data_attribute)
    return nil if data_attribute.nil?
    "#{data_attribute.cached} (#{data_attribute.type.demodulize.titleize.humanize})"
  end

end

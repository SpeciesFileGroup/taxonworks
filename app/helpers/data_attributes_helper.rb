module DataAttributesHelper

  def add_data_attribute_link(object: object, attribute: nil)
    link_to('Add data attribute', new_data_attribute_path(
      data_attribute: { 
          attribute_subject_type: object.class.base_class.name,
          attribute_subject_id: object.id})) if object.has_data_attributes?
  end

  def data_attribute_tag(data_attribute)
    return nil if data_attribute.nil?
    "#{data_attribute.controlled_vocabulary_term_id} (#{data_attribute.type.demodulize.titleize.humanize})"
  end


end

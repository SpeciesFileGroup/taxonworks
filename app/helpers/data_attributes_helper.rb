module DataAttributesHelper

  def data_attribute_tag(data_attribute)
    return nil if data_attribute.nil?
    (data_attribute_predicate_tag(data_attribute) + ' ' + data_attribute.value + ' on ' + object_tag(data_attribute.annotated_object) ).html_safe
  end

  def data_attribute_annotation_tag(data_attribute)
    return nil if data_attribute.nil?
    s = (data_attribute_predicate_tag(data_attribute) + ': ' + content_tag(:span, data_attribute.value, class: [:annotation__data_attribute_value]) ).html_safe
    content_tag(:span, s.html_safe, class: [:annotation__data_attribute])
  end

  def data_attribute_predicate_tag(data_attribute)
    return nil if data_attribute.nil?
    data_attribute.predicate_name 
   #if data_attribute.type == 'InternalAttribute'
   #  controlled_vocabulary_term_tag(data_attribute.metamorphosize.predicate)
   #elsif data_attribute.type == 'ImportAttribute'
   #  data_attribute.import_predicate
   #else
   #  nil
   #end
  end

  def data_attribute_list_tag(object)
    return nil unless object.has_data_attributes? && object.data_attributes.any?
    content_tag(:h3, 'Data attributes') +
      content_tag(:ul, class: 'annotations__data_attribute_list') do
      object.data_attributes.collect{|a| 
        content_tag(:li, data_attribute_annotation_tag(a)) 
      }.join.html_safe 
    end
  end

  def add_data_attribute_link(object: nil, attribute: nil)
    link_to('Add data attribute', new_data_attribute_path(
                                    data_attribute: {
                                        attribute_subject_type: object.class.base_class.name,
                                        attribute_subject_id: object.id})) if object.has_data_attributes?
  end
  
  def data_attribute_link(data_attribute)
    return nil if data_attribute.nil?
    link_to(object_tag(data_attribute).html_safe, data_attribute.annotated_object.metamorphosize)
  end

  def data_attributes_search_form
    render('/data_attributes/quick_search_form')
  end

  def data_attribute_edit_link(data_attribute)
    if data_attribute.metamorphosize.editable?
      link_to 'Edit', edit_data_attribute_path(data_attribute)
    else
      content_tag(:em, 'Edit')
    end
  end

end

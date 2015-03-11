module DataAttributesHelper

  def add_data_attribute_link(object: object, attribute: nil)
    link_to('Add data attribute', new_data_attribute_path(
                                    data_attribute: {
                                        attribute_subject_type: object.class.base_class.name,
                                        attribute_subject_id: object.id})) if object.has_data_attributes?
  end

  # TODO: add a cached?
  def data_attribute_tag(data_attribute)
    return nil if data_attribute.nil?
    if data_attribute.type == 'ImportAttribute'
      data_attribute.import_predicate + ": " + data_attribute.value 
    elsif data_attribute.type == 'InternalAttribute'
      data_attribute.predicate.name + ": " + data_attribute.value 
    else
      '!! WARNING: bad data attribute, contact your administrator !!' 
    end
  end

  def data_attribute_link(data_attribute)
    return nil if data_attribute.nil?
    link_to(data_attribute_tag(data_attribute).html_safe, data_attribute)
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

  def data_attribute_predicate_tag(data_attribute)
    if data_attribute.type == 'InternalAttribute'

      p = DataAttribute.find(data_attribute.id)
      p.predicate.name
    elsif data_attribute.type == 'ImportAttribute'
      data_attribute.import_predicate
    else
      'Notify admin, internal error'
    end
  end
end

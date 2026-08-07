module AlternateValuesHelper

  def alternate_value_tag(alternate_value)
    return nil if alternate_value.nil?
    [ alternate_value_string(alternate_value),
      tag.span("on '#{alternate_value.alternate_value_object_attribute}'", class: [:feedback, 'feedback-thin', 'feedback-secondary']),
      tag.span((alternate_value.project_id.nil? ? 'public' : 'project only'), class: [:feedback, 'feedback-thin', 'feedback-warning'])
    ].join('  ').html_safe
  end

  def alternate_value_string(alternate_value)
    ["\"#{alternate_value.value}\" ",
     alternate_value.klass_name,
     ' of ',
     # "#{alternate_value.alternate_value_object_attribute}",
     " \"#{alternate_value.original_value}\""].join
  end

  def alternate_value_annotation_tag(alternate_value)
    return nil if alternate_value.nil?
    content_tag(:span, alternate_value_string(alternate_value), class: [:annotation__alternate_value])
  end

  # @return [String (html), nil]
  #    a ul/li of alternate_values for the object
  def alternate_values_list_tag(object)
    return nil unless object.has_alternate_values? && object.alternate_values.any?
    content_tag(:h3, 'Alternate values') +
      content_tag(:ul, class: 'annotations__alternate_value_list') do
        object.alternate_values.collect { |a| content_tag(:li, alternate_value_annotation_tag(a)) }.join.html_safe
      end
  end

  def link_to_destroy_alternate_value(link_text, alternate_value)
    link_to(link_text, '', class: 'alternate-value-destroy', alternate_value_id: alternate_value.id)
  end

  def link_to_edit_alternate_value(link_text, alternate_value)
    link_to(link_text, '', class: 'alternate-value-edit', alternate_value_id: alternate_value.id)
  end

  def link_to_add_alternate_value(link_text, f)
    new_object =
      f.object.class.reflect_on_association(:alternate_values)
      .klass.new({alternate_value_object_type: f.object.class.base_class.name,
                  alternate_value_object_id: f.object.id,
                  alternate_value_object_attribute: 'name'})
    if f.object.alternate_values.any?
      fields = f.fields_for(:alternate_values, new_object,
                            child_index: 'new_alternate_values') do |builder|
                              render('alternate_values/alternate_value_fields', avf: builder)
                            end
    else
      fields = nil
    end
    link_to(link_text, '', class: 'alternate-value-add', association: 'alternate_values', content: "#{fields}")
  end

  def add_alternate_value_link(object: nil, attribute: nil)
    link_to('Add alternate value', new_alternate_value_path(
      alternate_value: {alternate_value_object_type: object.class.base_class.name,
                        alternate_value_object_id: object.id,
                        alternate_value_object_attribute: attribute})) if object.has_alternate_values?
  end

  def edit_alternate_value_link(alternate_value)
    edit_object_link(alternate_value)
    # link_to('Edit', edit_alternate_value_path(alternate_value))
  end

  def destroy_alternate_value_link(alternate_value)
    destroy_object_link(alternate_value)
  end

  def alternate_value_link(alternate_value)
    return nil if alternate_value.nil?
    link_to(alternate_value_tag(alternate_value).html_safe, alternate_value.annotated_object.metamorphosize)
  end

  def alternate_values_search_form
    render('/alternate_values/quick_search_form')
  end

  # @return [True]
  #   indicates a custom partial should be used, see list_helper.rb
  def alternate_values_recent_objects_partial
    true
  end

end

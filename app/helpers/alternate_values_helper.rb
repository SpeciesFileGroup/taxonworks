module AlternateValuesHelper

  def alternate_value_tag(alternate_value)
    return nil if alternate_value.nil?
    ["#{alternate_value.value},", alternate_value.class.name.demodulize.downcase, "of \"#{alternate_value.original_value}\"", "(on '#{alternate_value.alternate_value_object_attribute}')"].join(' ')
  end

  def link_to_destroy_alternate_value(link_text, alternate_value)
    link_to(link_text, '', class: 'alternate-value-destroy', alternate_value_id: alternate_value.id)
  end

  def link_to_edit_alternate_value(link_text, alternate_value)
    link_to(link_text, '', class: 'alternate-value-edit', alternate_value_id: alternate_value.id)
  end

  def link_to_add_alternate_value(link_text, f)
    new_object = f.object.class.reflect_on_association(:alternate_values).klass.new({alternate_value_object_type: f.object.class.base_class.name,
                                                                                     alternate_value_object_id: f.object.id,
                                                                                     alternate_value_object_attribute: 'name'})
    # new_object = AlternateValue.new(alternate_value_object_id:   f.object.id,
    #                                 alternate_value_object_type: f.object.class.base_class.name)
    # fields     = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
    #   render(association.to_s.singularize + "_fields", :f => builder)
    fields = f.fields_for(:alternate_values, new_object, :child_index => 'new_alternate_values') do |builder|
      render('alternate_values/alternate_value_fields', :avf => builder)
    end
    # link_to(link_text, '', id: "#{association[0]}-add", onclick: "add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")")
    # link_to(link_text, '', id: "#{association[0]}-add")
    # link_to(link_text, '', id: "#{association[0]}-add", fields: fields)
    link_to(link_text, '', class: 'alternate-value-add', association: 'alternate_values', content: "#{fields}")
  end

  def add_alternate_value_link(object: object, attribute: nil)
    link_to('Add alternate value', new_alternate_value_path(
        alternate_value: {alternate_value_object_type: object.class.base_class.name,
                          alternate_value_object_id: object.id,
                          alternate_value_object_attribute: attribute})) if object.respond_to?(:has_alternate_values?)
  end

  def edit_alternate_value_link(alternate_value)
    edit_object_link(alternate_value)
    # link_to('Edit', edit_alternate_value_path(alternate_value))
  end

  def destroy_alternate_value_link(alternate_value)
    destroy_object_link(alternate_value)
  end

end

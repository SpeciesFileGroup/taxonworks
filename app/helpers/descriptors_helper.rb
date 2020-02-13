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
 
  # @return [String]
  #   the column/descriptor name presented in the exported matrix 
  def descriptor_matrix_label(descriptor)
    descriptor.name.gsub(/[\W]/ , "_")
  end

  # @return [String, nil]
  #   state labels formatted for matrix export
  def descriptor_matrix_character_states_label(descriptor)
    if descriptor.qualitative?
      descriptor.character_states.map{|state| state.name.gsub(/[\W]/ , "_")}.join(" ")
    else 
      nil
    end
  end

end

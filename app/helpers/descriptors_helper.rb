module DescriptorsHelper

  def descriptor_tag(descriptor)
    return nil if descriptor.nil?
    descriptor.name
  end

  def label_for_descriptor(descriptor)
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

  def descriptors_autocomplete_tag(descriptor, term = nil)
    return nil if descriptor.nil?

    if term
      s = descriptor.name.gsub(/#{Regexp.escape(term)}/i, "<mark>#{term}</mark>")
    else
      s = descriptor.name
    end

    s += ' ' + content_tag(:span, descriptor.type.split('::').last, class: [:feedback, 'feedback-secondary', 'feedback-thin'])

    c = descriptor.observations.count
    if c > 0
      s += ' ' + content_tag(:span, "#{c.to_s}&nbsp;#{'observation'.pluralize(c)}".html_safe, class: [:feedback, 'feedback-info', 'feedback-thin'])
    end

    d = Observation.joins(:depictions).where(descriptor_id: descriptor.id).count
    if d > 0
      s += ' ' + content_tag(:span, "#{d.to_s}&nbsp;#{'observation depiction'.pluralize(d)}".html_safe, class: [:feedback, 'feedback-secondary', 'feedback-thin'])
    end

    e =  descriptor.observation_matrices.count
    s += ' '
    if e > 0
      s +=  content_tag(:span, "#{e.to_s}&nbsp;#{'matrix'.pluralize(e)}".html_safe, class: [:feedback, 'feedback-secondary', 'feedback-thin'])
    else
      s += content_tag(:span, "No matrix".html_safe, class: [:feedback, 'feedback-warning', 'feedback-thin'])
    end

    s.html_safe
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

  # @return [String]
  #   the column/descriptor name modified for comma seperated
  #     quote delimited CSV export
  def descriptor_matrix_label_csv(descriptor, quote = '"')
    quote + descriptor.name.gsub('"', "'") + quote
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

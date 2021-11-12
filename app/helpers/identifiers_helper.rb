module IdentifiersHelper

  # @return [String, nil]
  def identifier_tag(identifier)
    return nil if identifier.nil? || identifier.new_record?
    content_tag(:span, identifier.cached, title: identifier.type.demodulize.titleize.humanize)
  end

  # @return [String, nil]
  #   link to GET idnetifiers/:id
  def identifier_link(identifier)
    return nil if identifier.nil?
    link_to(identifier_tag(identifier).html_safe, identifier.identifier_object.metamorphosize)
  end

  # @return [String, nil]
  def identifier_annotation_tag(identifier)
    return nil if identifier.nil?
    content_tag(:span, identifier.cached, class: [:annotation__identifier])
  end

  # @return [String, nil]
  def identifier_autocomplete_tag(identifier)
    return nil if identifier.nil?
    content_tag(:span, class: :annotation__identifier) do
      [
        object_tag(identifier.annotated_object.metamorphosize),
        content_tag(:span, identifier.identifier_object_type, class: [:feedback, 'feedback-thin', 'feedback-primary']),
        content_tag(:span, identifier.type, class: [:feedback, 'feedback-thin', 'feedback-secondary']),
      ].join('&nbsp;').html_safe
    end
  end

  # @return [String, nil]
  def identifier_type_tag(identifier)
    return nil if identifier.nil?
    identifier.class.name.demodulize.underscore.humanize.downcase
  end

  # @return [String, nil]
  def identifier_short_tag(identifier)
    return nil if identifier.nil?
    content_tag(:span, identifier.cached, class: [:feedback, 'feedback-thin', 'feedback-primary'])
  end

  # TODO: Unify to helpers/README.md pattern
  def identifier_label(identifier)
    return nil if identifier.nil?
    identifier.cached
  end

  def label_for_identifier(identifier)
    return nil if identifier.nil?
    identifier.cached
  end

  # @return [String]
  #   assumes the display context is on the object in question
  def identifier_list_tag(object)
    return nil unless object.has_identifiers? && object.identifiers.any?
    content_tag(:h3, 'Identifiers') +
      content_tag(:ul, class: 'annotations_identifier_list') do
      object.identifiers.collect{|a| content_tag(:li, identifier_annotation_tag(a)) }.join.html_safe 
    end
  end

  # @return [String, nil]
  #   a list of identifiers *without* HTML
  def simple_identifier_list_tag(object)
    return nil if !object.identifiers.any?
    object.identifiers.collect{|a| content_tag(:span, identifier_annotation_tag(a)) }.join.html_safe
  end

  # @return [String, nil]
  #    identifiers for object with HTML
  def identifiers_tag(object)
    if object.identifiers.any?
      return object.identifiers.collect{|a| content_tag(:span, identifier_tag(a))}.join('; ').html_safe
    end
    nil
  end

  def add_identifier_link(object: nil)
    link_to('Add identifier', new_identifier_path(
      identifier: {
        identifier_object_type: object.class.base_class.name,
        identifier_object_id: object.id})) if object.has_identifiers?
  end

  def identifiers_search_form
    render('/identifiers/quick_search_form')
  end

  # @return [True]
  #   indicates a custom partial should be used, see list_helper.rb
  def identifiers_partial
    true 
  end

  # @return [True]
  #   indicates a custom partial should be used, see list_helper.rb
  def identifier_recent_objects_partial
    true 
  end
  
  def identifier_type_select_options
    a = []
    %I{global local unknown}.each do |t|
      a += IDENTIFIERS_JSON[t][:all].collect{|b,c| [c[:label], b]}
    end
    a
  end

end

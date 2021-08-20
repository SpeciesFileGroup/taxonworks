module ConfidencesHelper

  def confidence_tag(confidence)
    return nil if confidence.nil?
    controlled_vocabulary_term_tag(confidence.confidence_level)
  end

  def confidence_link(confidence)
    return nil if confidence.nil?
    link_to(confidence_tag(confidence), confidence.confidence_object.metamorphosize)
  end

  # @return [String (html), nil]
  #    a ul/li of tags for the object
  def confidence_list_tag(object)
    return nil unless object.has_confidences? && object.confidences.any?
    content_tag(:h3, 'Confidences') +
      content_tag(:ul, class: 'annotations__confidences_list') do
      object.confidences.collect { |a| content_tag(:li, confidence_tag(a)) }.join.html_safe
    end
  end

  def confidence_annotation_confidence(confidence)
    return nil if confidence.nil?
    content_tag(:span, controlled_vocabulary_term_tag(confidence.confidence_level), class: [:annotation__confidence])
  end

  def confidences_search_form
    render('/confidences/quick_search_form')
  end

  def inserted_confidence_level_count
    inserted_confidence_level.try(:confidences).try(:count)
  end

  def inserted_confidence_level
    inserted_pinboard_item_object_for_klass('ConfidenceLevel')
  end

  def confidence_default_icon(object)
    content_tag(:div, '', data: {
      'confidence-default' => 'true',
      'confidence-object-global-id' => object.to_global_id.to_s,
      'default-confidenced-id' => is_default_confidenced?(object), 
      'inserted-confidence-level-count' => inserted_confidence_level_count  })
  end

  # @return [Integer, false]
  #   true if the object has the confidence level, and is annotated with the confidence level presently defaulted on the pinboard
  def is_default_confidenced?(object)
    return false if object.blank?
    confidence_level = inserted_confidence_level
    return false if confidence_level.blank?
    t = Confidence.where(confidence_object: object, confidence_level: confidence_level).first.try(:id)
    t ? t : false
  end

  def add_confidence_link(object: nil)
    link_to('Add confidence', new_confidence_path(
      confidence_object_type: object.class.base_class.name,
      confidence_object_id: object.id
    )) if object.has_confidences?
  end

end

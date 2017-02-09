module ConfidencesHelper

  def confidence_tag(confidence)
    return nil if confidence.nil?
    content_tag(:span, confidence.confidence_level.name, style: "background-color: #{confidence.confidence_level.css_color};")
  end

  def confidence_link(confidence)
    return nil if confidence.nil?
    link_to(confidence_tag(confidence), confidence)
  end

  def confidences_search_form
    render('/confidences/quick_search_form')
  end

  def add_confidence_link(object: nil)
    link_to('Add confidence', new_confidence_path( 
                                                  confidence_object_type: object.class.base_class.name,
                                                  confidence_object_id: object.id
                                                 )) if object.has_confidences?
  end

end

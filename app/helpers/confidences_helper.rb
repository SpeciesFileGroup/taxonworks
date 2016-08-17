module ConfidencesHelper
  def confidence_tag(confidence)
    return nil if confidence.nil?
    confidence.id.to_s
  end

  def confidence_link(confidence)
    return nil if confidence.nil?
    link_to(confidence_tag(confidence.html), confidence)
  end

  def confidences_search_form
    render('/confidences/quick_search_form')
  end
end

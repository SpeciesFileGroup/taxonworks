# Helpers that wrap sets of annotations of different types.
module AnnotationsHelper 

  # @return [String]
  # Assumes the context is the object, not a multi-object summary
  def annotations_summary_tag(object)
    content_tag(:div, class: [:content]) + 
    content_tag(:h2, 'Annotations', class: [:annotation__summary, 'title-section']) +
      ( 
       identifier_list_tag(object) +
       data_attribute_list_tag(object) +
       note_list_tag(object) +
       tag_list_tag(object) 
      ).html_safe


    # depictions
    # confidences
    # protocols
    # alternate values


  end


end

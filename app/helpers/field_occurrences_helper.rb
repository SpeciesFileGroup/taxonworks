module FieldOccurrencesHelper

  # Return [String, nil]
  #   a descriptor including the identifier and determination
  def field_occurrence_tag(field_occurrence)
    return nil if field_occurrence.nil?
   [ 
     field_occurrence_total_tag(field_occurrence),
     field_occurrence_taxon_determination_tag(field_occurrence),
     field_occurrence_collecting_event_tag(field_occurrence),
   ].compact.join('&nbsp;').html_safe
  end

  def field_occurrence_total_tag(field_occurrence)
    return nil if field_occurrence.nil? 
    # TODO: ranged lot extension
    tag.span(field_occurrence.total, class: [:feedback, 'feedback-thin', 'feedback-info'])
  end

  def field_occurrence_collecting_event_tag(field_occurrence)
    return nil if field_occurrence.nil? 
    # TODO: ranged lot extension
    tag.span(collecting_event_tag(field_occurrence.collecting_event), class: [:feedback, 'feedback-thin', 'feedback-secondary'])
  end

  def field_occurrence_taxon_determination_tag(field_occurrence)
    return nil if field_occurrence.nil? 
    # TODO: ranged lot extension
    tag.span(taxon_determination_tag(field_occurrence.taxon_determination), class: [:feedback, 'feedback-thin'])
  end

  def label_for_field_occurrence(field_occurrence)
    return nil if field_occurrence.nil?
    [ 'FieldOccurrence ' + field_occurrence.id.to_s,
      identifier_list_labels(field_occurrence),
      label_for_collecting_event(field_occurrence.collecting_event)
    ].compact.join('; ')
  end

  def field_occurrence_autocomplete_tag(field_occurrence)
    return nil if field_occurrence.nil?
    [
      field_occurrence_tag(field_occurrence)
    ].join(' ').html_safe
  end

  def field_occurrences_search_form
    render('/field_occurrences/quick_search_form')
  end

end

module FieldOccurrencesHelper

  # Return [String, nil]
  #   a descriptor including the identifier and determination
  def field_occurrence_tag(field_occurrence)
    return nil if field_occurrence.nil?
    a = [
      taxon_determination_tag(field_occurrence.taxon_determinations.order(:position).first)
    ].compact

    a.join('&nbsp;').html_safe
  end

  def label_for_field_occurrence(field_occurrence)
    return nil if field_occurrence.nil?
    [ 'FieldOccurrence ' + field_occurrence.id.to_s,
      identifier_list_labels(field_occurrence)
    ].compact.join('; ')
  end

  def field_occurrence_autocomplete_tag(field_occurrence)
    return nil if field_occurrence.nil?
    [
      field_occurrence_taxon_determination_tag(field_occurrence)
    ].join(' ').html_safe
  end

end

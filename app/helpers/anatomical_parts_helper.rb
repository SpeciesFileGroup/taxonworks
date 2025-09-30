module AnatomicalPartsHelper
  def anatomical_part_tag(anatomical_part)
    return nil if anatomical_part.nil?

    anatomical_part.cached
  end

  def anatomical_part_autocomplete_tag(anatomical_part)
    anatomical_part_tag(anatomical_part)
  end

  def label_for_anatomical_part(anatomical_part)
    anatomical_part_tag(anatomical_part)
  end

  def anatomical_parts_search_form
    render('/anatomical_parts/quick_search_form')
  end

  def anatomical_part_graph_label_for_related_object(obj)
    case obj.class.base_class.name
    when 'AnatomicalPart'
      'AnatomicalPart: ' + label_for_anatomical_part(obj)
    when 'CollectionObject'
      label_for_collection_object(obj)
    when 'Extract'
      'Extract: ' + label_for_extract(obj)
    when 'FieldOccurrence'
      label_for_field_occurrence(obj)
    when 'Otu'
      'Otu: ' + label_for_otu(obj)
    when 'Sequence'
      'Sequence: ' + label_for_sequence(obj)
    when 'Sound'
      'Sound: ' + label_for_sound(obj)
    end
  end
end

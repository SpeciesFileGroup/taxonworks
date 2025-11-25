module AnatomicalPartsHelper
  def anatomical_part_tag(anatomical_part)
    return nil if anatomical_part.nil?

    "#{anatomical_part.cached}: #{otu_tag(anatomical_part.origin_otu)}"
  end

  def anatomical_part_autocomplete_tag(anatomical_part)
    anatomical_part_tag(anatomical_part)
  end

  def label_for_anatomical_part(anatomical_part)
    return nil if anatomical_part.nil?

    "#{anatomical_part.cached}: #{label_for_otu(anatomical_part.origin_otu)}"
  end

  def label_for_anatomical_part_container(anatomical_part)
    return nil if anatomical_part.nil?
    anatomical_part.cached
  end

  def anatomical_parts_search_form
    render('/anatomical_parts/quick_search_form')
  end

  def anatomical_part_ontology_label(ols_result)
    r = ols_result

    description = r[:description].present? ? ": #{r[:description]}" : ''

    "#{r[:label]} (#{r[:ontology_prefix]})#{description}"
  end

  def anatomical_part_graph_label_for_related_object(obj)
    case obj.class.base_class.name
    when 'AnatomicalPart'
      'AnatomicalPart: ' + (label_for_anatomical_part(obj) || '(no label)')
    when 'CollectionObject'
      label_for_collection_object(obj)
    when 'Extract'
      'Extract: ' + (label_for_extract(obj) || '(no label)')
    when 'FieldOccurrence'
      label_for_field_occurrence(obj)
    when 'Otu'
      'Otu: ' + (label_for_otu(obj) || '(no label)')
    when 'Sequence'
      'Sequence: ' + (label_for_sequence(obj) || '(no label)')
    when 'Sound'
      'Sound: ' + (label_for_sound(obj) || '(no label)')
    end
  end
end

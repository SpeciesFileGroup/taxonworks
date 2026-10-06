module AnatomicalPartsHelper
  def anatomical_part_tag(anatomical_part, depth: 0)
    return nil if anatomical_part.nil?
    raise "AnatomicalPart origin chain exceeded maximum depth, possible cycle at id #{anatomical_part.id}" if depth > 100

    origin = anatomical_part.inbound_origin_relationship&.old_object
    origin_content = case origin&.class&.base_class&.name
    when 'Otu'
      otu_tag(origin)
    when 'CollectionObject'
      collection_object_tag(origin)
    when 'FieldOccurrence'
      field_occurrence_tag(origin)
    when 'AnatomicalPart'
      anatomical_part_tag(origin, depth: depth + 1)
    else
      otu_tag(anatomical_part.origin_otu)
    end

    content_tag(:span, safe_join([anatomical_part.cached, ': ', origin_content || '']))
  end

  def anatomical_part_autocomplete_tag(anatomical_part, term = nil)
    mark_tag(anatomical_part_tag(anatomical_part), term)
  end

  def label_for_anatomical_part(anatomical_part, depth: 0)
    return nil if anatomical_part.nil?
    raise "AnatomicalPart origin chain exceeded maximum depth, possible cycle at id #{anatomical_part.id}" if depth > 100

    origin = anatomical_part.inbound_origin_relationship&.old_object
    origin_label = case origin&.class&.base_class&.name
    when 'Otu'
      label_for_otu(origin)
    when 'CollectionObject'
      "#{label_for_collection_object(origin)} (#{label_for_otu(anatomical_part.origin_otu)})"
    when 'FieldOccurrence'
      "#{label_for_field_occurrence(origin)} (#{label_for_otu(anatomical_part.origin_otu)})"
    when 'AnatomicalPart'
      label_for_anatomical_part(origin, depth: depth + 1)
    else
      label_for_otu(anatomical_part.origin_otu)
    end

    "#{anatomical_part.cached}: #{origin_label}"
  end

  def short_label_for_anatomical_part(anatomical_part)
    return nil if anatomical_part.nil?

    anatomical_part.cached
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
    # We expect this to always be present and it usually is, but sometimes it
    # isn't.
    ontology_prefix = r[:ontology_prefix] ? "(#{r[:ontology_prefix]})" : ''
    "#{r[:label]} #{ontology_prefix}#{description}"
  end

  def anatomical_part_ontology_autocomplete_label(ols_result, project_count: 0)
    label = anatomical_part_ontology_label(ols_result)

    if project_count > 0
      in_project_tag = content_tag(:span, 'In project', class: 'feedback feedback-primary feedback-thin')
      in_project_count_tag = content_tag(:span, project_count, class: 'feedback feedback-secondary feedback-thin')
      safe_join([label, ' ', in_project_tag, ' ', in_project_count_tag])
    else
      label
    end
  end

  def anatomical_part_graph_label_for_related_object(obj)
    case obj.class.base_class.name
    when 'AnatomicalPart'
      'AnatomicalPart: ' + (short_label_for_anatomical_part(obj) || '(no label)')
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

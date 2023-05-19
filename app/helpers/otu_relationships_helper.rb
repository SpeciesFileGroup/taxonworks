module OtuRelationshipsHelper

  def otu_relationship_tag(otu_relationship)
    return nil if otu_relationship.nil?
    [otu_tag(otu_relationship.subject_otu), otu_relationship_type_label(otu_relationship), otu_tag(otu_relationship.object_otu) ].compact.join(' ')
  end

  def otu_relationship_label(otu_relationship)
    return nil if otu_relationship.nil?
    [
      label_for_otu(otu_relationship.subject_otu),
      tag.span(otu_relationship_type_label(otu_relationship), class: [:feedback, 'feedback-thin', 'feedback-info']),
      label_for_otu(otu_relationship.object_otu) ].compact.join(' ').html_safe
  end

  def otu_relationship_link(otu_relationship)
    return nil if otu_relationship.nil?
    link_to(otu_relationship_label(otu_relationship), otu_relationship.metamorphosize)
  end

  def otu_relationship_type_label(otu_relationship)
    return nil if otu_relationship.nil?
    case otu_relationship.type
    when 'OtuRelationship::Disjoint'
      'disjoint'
    when 'OtuRelationship::Equal'
      'equals'
    when 'OtuRelationship::Intersecting'
      'intersecting'
    when 'OtuRelationship::PartiallyOverlapping'
      'overlaps'
    when 'OtuRelationship::ProperPartInverse'
      'includes'
    when 'OtuRelationship::ProperPart'
       'included in'
    end

  end

end

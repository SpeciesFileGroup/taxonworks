module OtuRelationshipsHelper

  def otu_relationship_tag(otu_relationship)
    return nil if otu_relationship.nil?
    [otu_tag(otu_relationship.subject_otu), otu_relationship_type_label(otu_relationship), otu_tag(otu_relationship.object_otu) ].compact.join(' ')
  end

  def otu_relationship_label(otu_relationship)
    return nil if otu_relationship.nil?
    [label_for_otu(otu_relationship.subject_otu), otu_relationship.type_name, label_for_otu(otu_relationship.object_otu) ].compact.join(' ')
  end

  def otu_relationship_link(otu_relationship)
    return nil if otu_relationship.nil?
    link_to(otu_relationship, otu_relationship_label(otu_relationship))
  end

  def otu_relationship_type_label(otu_relationship)
    return nil if otu_relationship.nil?
    otu_relationship.type_name
  end

end

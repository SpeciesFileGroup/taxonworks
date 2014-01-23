class TaxonNameRelationship::Icn::Unaccepting < TaxonNameRelationship::Icn

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_to_s(TaxonNameRelationship::Icn::Accepting)
  end

  def self.disjoint_object_classes
    self.parent.disjoint_object_classes +
        self.collect_descendants_to_s(TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished,
            TaxonNameClassification::Icn::NotEffectivelyPublished,
            TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate)
  end

  def self.subject_relationship_name
    'unaccepted name'
  end

  def self.object_relationship_name
    'accepted name'
  end

  def self.assignable
    true
  end

  def self.nomenclatural_priority
    :direct
  end

  def self.assignment_method
    # aus.icn_unacceptable = bus
    :icn_unacceptable
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_icn_unacceptable_of(aus)
    :set_as_icn_unacceptable_of
  end

end
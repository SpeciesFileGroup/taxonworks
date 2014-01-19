class TaxonNameRelationship::Icn::Unaccepting::Rejected < TaxonNameRelationship::Icn::Unaccepting

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Icn::Unaccepting.to_s] +
        TaxonNameRelationship::Icn::Unaccepting::Usage.descendants.collect{|t| t.to_s}
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        [TaxonNameClassification::Icn::NotEffectivelyPublished.to_s] +
        TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished.descendants.collect{|t| t.to_s} +
        TaxonNameClassification::Iczn::EffectivelyPublished::ValidlyPublished::Legitimate.descendants.collect{|t| t.to_s}
  end

  def self.subject_relationship_name
    'rejected'
  end

  def self.object_relationship_name
    'conserved'
  end

  def self.priority
    :reverse
  end

  def self.assignment_method
    # aus.icn_rejected = bus
    :icn_rejected
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_icn_rejected_of(aus)
    :set_as_icn_rejected_of
  end

end
class TaxonNameRelationship::Icn::Unaccepting::Usage::Basionym < TaxonNameRelationship::Icn::Unaccepting::Usage

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Icn::Unaccepting::Usage::Misspelling.to_s] +
        [TaxonNameRelationship::Icn::Unaccepting::Usage::Misapplication.to_s]
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        [TaxonNameClass::Icn::NotEffectivelyPublished.to_s] +
        TaxonNameClass::Icn::EffectivelyPublished::InvalidlyPublished.descendants.collect{|t| t.to_s} +
        TaxonNameClass::Iczn::EffectivelyPublished::ValidlyPublished::Illegitimate.descendants.collect{|t| t.to_s}
  end

  def self.subject_relationship_name
    'basionym'
  end

  def self.assignment_method
    # aus.icn_basionym = bus
    :icn_basionym
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_icn_basionym_of(aus)
    :set_as_icn_basionym_of
  end

end
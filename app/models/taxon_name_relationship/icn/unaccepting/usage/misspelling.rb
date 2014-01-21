class TaxonNameRelationship::Icn::Unaccepting::Usage::Misspelling < TaxonNameRelationship::Icn::Unaccepting::Usage

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships + self.collect_to_s(
        TaxonNameRelationship::Icn::Unaccepting::Usage::Basionym,
        TaxonNameRelationship::Icn::Unaccepting::Usage::Misapplication)
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes + self.collect_descendants_to_s(
        TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished,
        TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished.Legitimate) + self.collect_to_s(
        TaxonNameClassification::Icn::NotEffectivelyPublished,
        TaxonNameClassification::Iczn::EffectivelyPublished::ValidlyPublished::Illegitimate::Homonym,
        TaxonNameClassification::Iczn::EffectivelyPublished::ValidlyPublished::Illegitimate::Seperfluous)         
  end

  def self.subject_relationship_name
    'misspelling'
  end

  def self.object_relationship_name
    'correct spelling'
  end


  def self.assignment_method
    # aus.icn_misspelling = bus
    :icn_misspelling
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_icn_misspelling_of(aus)
    :set_as_icn_misspelling_of
  end

end
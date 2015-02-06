class TaxonNameRelationship::Icn::Unaccepting::Usage::Misspelling < TaxonNameRelationship::Icn::Unaccepting::Usage

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000375'

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icn::Unaccepting::Usage::Basionym,
            TaxonNameRelationship::Icn::Unaccepting::Usage::Misapplication)
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished,
            TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate) +
        self.collect_to_s(TaxonNameClassification::Icn::NotEffectivelyPublished,
        TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate::Homonym,
        TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate::Superfluous)
  end

  def self.subject_relationship_name
    'correct spelling'
  end

  def self.object_relationship_name
    'misspelling'
  end

  def self.gbif_status_of_subject
    'nullum'
  end

  def self.assignment_method
    # bus.set_as_icn_misspelling_of(aus)
    :icn_set_as_misspelling_of
  end

  def self.inverse_assignment_method
    # aus.icn_misspelling = bus
    :icn_misspelling
  end

end
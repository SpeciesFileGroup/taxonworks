class TaxonNameRelationship::Icnp::Unaccepting::Usage::Misspelling < TaxonNameRelationship::Icnp::Unaccepting::Usage

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000099'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Icnp::EffectivelyPublished::InvalidlyPublished,
            TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Legitimate) +
        self.collect_to_s(TaxonNameClassification::Icnp::NotEffectivelyPublished)
  end

  def object_status
    'correct spelling'
  end

  def subject_status
    'misspelling'
  end

  def self.gbif_status_of_subject
    'nullum'
  end

  def self.assignment_method
    # bus.set_as_icn_misspelling_of(aus)
    :icnp_set_as_misspelling_of
  end

  def self.inverse_assignment_method
    # aus.icn_misspelling = bus
    :icnp_misspelling
  end

end
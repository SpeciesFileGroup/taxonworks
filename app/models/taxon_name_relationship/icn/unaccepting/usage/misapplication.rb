class TaxonNameRelationship::Icn::Unaccepting::Usage::Misapplication < TaxonNameRelationship::Icn::Unaccepting::Usage

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000376'

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icn::Unaccepting::Usage::Basionym,
            TaxonNameRelationship::Icn::Unaccepting::Usage::Misspelling)
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        self.collect_to_s(TaxonNameClassification::Icn::NotEffectivelyPublished) +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished,
            TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate)
  end

  def subject_relationship_name
    'correct application'
  end

  def object_relationship_name
    'misapplication'
  end

  def self.gbif_status_of_subject
    'ambigua'
  end

  def self.assignment_method
    # bus.set_as_icn_misapplication_of(aus)
    :icn_set_as_misapplication_of
  end

  def self.inverse_assignment_method
    # aus.icn_misapplication = bus
    :icn_misapplication
  end

end
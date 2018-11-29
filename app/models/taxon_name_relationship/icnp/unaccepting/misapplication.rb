class TaxonNameRelationship::Icnp::Unaccepting::Misapplication < TaxonNameRelationship::Icnp::Unaccepting

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000100'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icnp::Unaccepting::Synonym,
            TaxonNameRelationship::Icnp::Unaccepting::Homonym,
            TaxonNameRelationship::Icnp::Unaccepting::Usage)
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        self.collect_to_s(TaxonNameClassification::Icnp::NotEffectivelyPublished) +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Icnp::EffectivelyPublished::InvalidlyPublished,
            TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Illegitimate)
  end

  def subject_properties
    [ TaxonNameClassification::Icnp::NotEffectivelyPublished ]
  end


  def object_status
    'correct application'
  end

  def subject_status
    'misapplication'
  end

  def self.gbif_status_of_subject
    'ambigua'
  end

  def self.assignment_method
    # bus.set_as_icn_misapplication_of(aus)
    :icnp_set_as_misapplication_of
  end

  def self.inverse_assignment_method
    # aus.icn_misapplication = bus
    :icnp_misapplication
  end

end
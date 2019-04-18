class TaxonNameRelationship::Icnp::Unaccepting::Synonym < TaxonNameRelationship::Icnp::Unaccepting

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000096'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icnp::Unaccepting) +
        self.collect_descendants_to_s(TaxonNameRelationship::Icnp::Unaccepting::Usage)
  end

  def subject_properties
    [ TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Illegitimate ]
  end

  def object_status
    'synonym'
  end

  def subject_status
    'junior synonym'
  end

  def self.assignment_method
    # bus.set_as_icn_synonym_of(aus)
    :icnp_set_as_synonym_of
  end

  def self.inverse_assignment_method
    # aus.icn_synonym = bus
    :icnp_synonym
  end

end
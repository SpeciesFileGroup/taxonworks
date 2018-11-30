class TaxonNameRelationship::Icnp::Unaccepting::Synonym::Heterotypic < TaxonNameRelationship::Icnp::Unaccepting::Synonym

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000102'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icnp::Unaccepting::Synonym) +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Icnp::Unaccepting::Synonym::Homotypic)
  end

  def object_status
    'heterotypic earlier synonym'
  end

  def subject_status
    'heterotypic later synonym'
  end

  def self.assignment_method
    # bus.set_as_icn_heterotypic_synonym_of(aus)
    :icnp_set_as_subjective_synonym_of
  end

  def self.inverse_assignment_method
    # aus.icn_heterotypic_synonym = bus
    :icnp_subjective_synonym
  end

end
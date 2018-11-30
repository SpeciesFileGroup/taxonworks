class TaxonNameRelationship::Icnp::Unaccepting::Synonym::Homotypic < TaxonNameRelationship::Icnp::Unaccepting::Synonym

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000101'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icnp::Unaccepting::Synonym,
                          TaxonNameRelationship::Icnp::Unaccepting::Synonym::Heterotypic)
  end

  def object_status
    'homotypic earlier synonym'
  end

  def subject_status
    'homotypic later synonym'
  end

  def self.assignment_method
    # bus.set_as_icn_homotypic_synonym_of(aus)
    :icnp_set_as_objective_synonym_of
  end

  def self.inverse_assignment_method
    # aus.icn_homotypic_synonym = bus
    :icnp_objective_synonym
  end

end
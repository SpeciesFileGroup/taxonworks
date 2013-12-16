class TaxonNameRelationship::Icn::Unaccepting::Synonym::Heterotypic < TaxonNameRelationship::Icn::Unaccepting::Synonym

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Icn::Unaccepting::Synonym.to_s] +
        TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic.descendants.collect{|t| t.to_s}
  end

  def self.assignment_method
    # aus.icn_heterotypic_synonym = bus
    :icn_heterotypic_synonym
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_icn_heterotypic_synonym_of(aus)
    :set_as_icn_heterotypic_synonym_of
  end

end
class TaxonNameRelationship::Icn::Unaccepting::Synonym::Heterotypic < TaxonNameRelationship::Icn::Unaccepting::Synonym

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icn::Unaccepting::Synonym) +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic)
  end

  def self.subject_relationship_name
    'heterotypic synonym'
  end

  def self.object_relationship_name
    'heterotypic senior synonym'
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
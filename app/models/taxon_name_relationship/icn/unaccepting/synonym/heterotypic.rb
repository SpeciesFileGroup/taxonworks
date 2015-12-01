class TaxonNameRelationship::Icn::Unaccepting::Synonym::Heterotypic < TaxonNameRelationship::Icn::Unaccepting::Synonym

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000392'

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icn::Unaccepting::Synonym) +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic)
  end

  def subject_relationship_name
    'heterotypic senior synonym'
  end

  def object_relationship_name
    'heterotypic synonym'
  end

  def self.assignment_method
    # bus.set_as_icn_heterotypic_synonym_of(aus)
    :icn_set_as_heterotypic_synonym_of
  end

  def self.inverse_assignment_method
    # aus.icn_heterotypic_synonym = bus
    :icn_heterotypic_synonym
  end

end
class TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic < TaxonNameRelationship::Icn::Unaccepting::Synonym

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000393'

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icn::Unaccepting::Synonym,
            TaxonNameRelationship::Icn::Unaccepting::Synonym::Heterotypic)
  end

  def self.subject_relationship_name
    'homotypic senior synonym'
  end

  def self.object_relationship_name
    'homotypic synonym'
  end

  def self.assignment_method
    # bus.set_as_icn_homotypic_synonym_of(aus)
    :icn_set_as_homotypic_synonym_of
  end

  def self.inverse_assignment_method
    # aus.icn_homotypic_synonym = bus
    :icn_homotypic_synonym
  end

end
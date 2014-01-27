class TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::Isonym < TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic,
            TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::AlternativeName,
            TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::OrthographicVariant)
  end

  def self.subject_relationship_name
    'set as isonym'
  end

  def self.object_relationship_name
    'isonym'
  end

  def self.assignment_method
    # bus.set_as_icn_isonym_of(aus)
    :icn_set_as_isonym_of
  end

  # as.
  def self.inverse_assignment_method
    # aus.icn_isonym = bus
    :icn_isonym
  end

end
class TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::Isonym < TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000396'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic,
            TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::AlternativeName,
            TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::OrthographicVariant,
            TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::Basionym)
  end

  def object_status
    'set as isonym'
  end

  def subject_status
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
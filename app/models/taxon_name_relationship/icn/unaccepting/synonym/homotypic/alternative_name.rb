class TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::AlternativeName < TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000394'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic,
            TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::Isonym,
            TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::OrthographicVariant,
            TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::Basionym)
  end

  def object_status
    'set as alternative name'
  end

  def subject_status
    'alternative name'
  end

  def self.gbif_status_of_subject
    'alternativum'
  end

  def self.assignment_method
    # bus.set_as_icn_alternative_name_of(aus)
    :icn_set_as_alternative_name_of
  end

  # as.
  def self.inverse_assignment_method
    # aus.icn_alternative_name = bus
    :icn_alternative_name
  end

end
class TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::AlternativeName < TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic,
            TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::Isonym,
            TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::OrthographicVariant)
  end

  def self.subject_relationship_name
    'set as alternative name'
  end

  def self.object_relationship_name
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
class TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::OrthographicVariant < TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic,
            TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::AlternativeName,
            TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::Isonym)
  end

  def self.subject_relationship_name
    'correct orthographic variant'
  end

  def self.object_relationship_name
    'orthographic variant'
  end

  def self.gbif_status_of_subject
    'orthographia'
  end

  def self.assignment_method
    # bus.set_as_icn_orthographic_variant_of(aus)
    :icn_set_as_orthographic_variant_of
  end

  # as.
  def self.inverse_assignment_method
    # aus.icn_orthographic_variant = bus
    :icn_orthographic_variant
  end

end
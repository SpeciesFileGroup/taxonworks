class TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::OrthographicVariant < TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic.to_s] +
        [TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::AlternativeName.to_s] +
        [TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic::Isonym.to_s]
  end

  def self.assignment_method
    # aus.icn_orthographic_variant = bus
    :icn_orthographic_variant
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_icn_orthographic_variant_of(aus)
    :set_as_icn_orthographic_variant_of
  end

end
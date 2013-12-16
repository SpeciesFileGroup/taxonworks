class TaxonNameRelationship::Icn::Unaccepting::Usage::Misspelling < TaxonNameRelationship::Icn::Unaccepting::Usage

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Icn::Unaccepting::Usage::Basionym.to_s] +
        [TaxonNameRelationship::Icn::Unaccepting::Usage::Misapplication.to_s]
  end

  def self.assignment_method
    # aus.icn_misspelling = bus
    :icn_misspelling
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_icn_misspelling_of(aus)
    :set_as_icn_misspelling_of
  end

end
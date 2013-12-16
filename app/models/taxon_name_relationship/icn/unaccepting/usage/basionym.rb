class TaxonNameRelationship::Icn::Unaccepting::Usage::Basionym < TaxonNameRelationship::Icn::Unaccepting::Usage

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Icn::Unaccepting::Usage::Misspelling.to_s] +
        [TaxonNameRelationship::Icn::Unaccepting::Usage::Misapplication.to_s]
  end

  def self.assignment_method
    # aus.icn_basionym = bus
    :icn_basionym
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_icn_basionym_of(aus)
    :set_as_icn_basionym_of
  end

end
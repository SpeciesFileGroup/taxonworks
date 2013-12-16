class TaxonNameRelationship::Icn::Unaccepting::Usage::Misapplication < TaxonNameRelationship::Icn::Unaccepting::Usage

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Icn::Unaccepting::Usage::Basionym.to_s] +
        [TaxonNameRelationship::Icn::Unaccepting::Usage::Misspelling.to_s]
  end

  def self.assignment_method
    # aus.icn_misapplication = bus
    :icn_misapplication
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_icn_misapplication_of(aus)
    :set_as_icn_misapplication_of
  end

end
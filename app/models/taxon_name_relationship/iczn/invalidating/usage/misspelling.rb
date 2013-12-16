class TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling < TaxonNameRelationship::Iczn::Invalidating::Usage

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Iczn::Invalidating::Usage::Misidentification.descendants.collect{|t| t.to_s}
  end

  def self.assignment_method
    # aus.misspelling = bus
    :iczn_misspelling
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_misspelling_of(aus)
    :set_as_iczn_misspelling_of
  end

end
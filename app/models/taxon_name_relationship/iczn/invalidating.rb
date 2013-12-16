class TaxonNameRelationship::Iczn::Invalidating < TaxonNameRelationship::Iczn

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Iczn::Validating.descendants.collect{|t| t.to_s} +
        [TaxonNameRelationship::Iczn::Validating.to_s]
  end

  def self.assignable
    true
  end

  def self.assignment_method
    # aus.iczn_invalid = bus   ## Equal to synonym in broad sense
    :iczn_invalid
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_iczn_invalid_of(aus)
    :set_as_iczn_invalid_of
  end


end

class TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Partial < TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Conditional.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Total.to_s]
  end

  def self.subject_relationship_name
    'partially suppressed name'
  end

  def self.assignment_method
    # aus.iczn_partial_suppression = bus
    :iczn_partial_suppression
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_iczn_partial_suppression_of(aus)
    :set_as_iczn_partial_suppression
  end

end
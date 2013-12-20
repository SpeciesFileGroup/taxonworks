class TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Conditional < TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Partial.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Total.to_s]
  end

  def self.subject_relationship_name
    'conditionaly suppressed name'
  end

  def self.assignment_method
    # aus.iczn_conditional_suppression = bus
    :iczn_conditional_suppression
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_iczn_conditional_suppression_of(aus)
    :set_as_iczn_conditional_suppression
  end

end
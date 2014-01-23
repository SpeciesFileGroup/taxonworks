class TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Total < TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Partial,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Conditional)
  end

  def self.subject_relationship_name
    'totally suppressed name'
  end

  def self.assignment_method
    # aus.iczn_total_suppression = bus
    :iczn_total_suppression
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_iczn_total_suppression_of(aus)
    :set_as_iczn_total_suppression
  end

end
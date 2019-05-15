class TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Conditional < TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000282'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Partial,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Total)
  end

  def object_status
    'conserved'
  end

  def subject_status
    'conditionaly suppressed'
  end

  def self.assignment_method
    # bus.set_as_iczn_conditional_suppression_of(aus)
    :iczn_set_as_conditional_suppression_of
  end

  def self.inverse_assignment_method
    # aus.iczn_conditional_suppression = bus
    :iczn_conditional_suppression
  end

end
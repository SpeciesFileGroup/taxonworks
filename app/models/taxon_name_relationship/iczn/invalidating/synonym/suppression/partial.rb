class TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Partial < TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000281'.freeze

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Conditional,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Total)
  end

  def object_status
    'conserved'
  end

  def subject_status
    'partially suppressed'
  end

  def self.assignment_method
    # bus.set_as_iczn_partial_suppression_of(aus)
    :iczn_set_as_partial_suppression_of
  end

  def self.inverse_assignment_method
    # aus.iczn_partial_suppression = bus
    :iczn_partial_suppression
  end

end
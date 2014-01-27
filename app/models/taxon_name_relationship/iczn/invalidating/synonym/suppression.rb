class TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression < TaxonNameRelationship::Iczn::Invalidating::Synonym

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        self.collect_descendants_and_itself_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective) +
        self.collect_to_s(TaxonNameRelationship::Iczn::Invalidating::Synonym,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName,
            TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective)
  end

  def self.subject_relationship_name
    'conserved'
  end

  def self.object_relationship_name
    'suppressed'
  end

  def self.nomenclatural_priority
    :reverse
  end

  def self.assignment_method
    # bus.set_as_iczn_suppression_of(aus)
    :iczn_set_as_suppression_of
  end

  # as.
  def self.inverse_assignment_method
    # aus.iczn_suppression = bus
    :iczn_suppression
  end

end

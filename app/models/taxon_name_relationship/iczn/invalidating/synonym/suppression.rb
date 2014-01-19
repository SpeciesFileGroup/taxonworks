class TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression < TaxonNameRelationship::Iczn::Invalidating::Synonym

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective.descendants.collect{|t| t.to_s} +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::FamilyBefore1961.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective.to_s]
  end

  def self.subject_relationship_name
    'suppressed name'
  end

  def self.object_relationship_name
    'conserved name'
  end

  def self.priority
    :reverse
  end

  def self.assignment_method
    # aus.iczn_suppression = bus
    :iczn_suppression
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_iczn_suppression_of(aus)
    :set_as_iczn_suppression_of
  end

end

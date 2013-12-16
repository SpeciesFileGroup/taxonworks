class TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName < TaxonNameRelationship::Iczn::Invalidating::Synonym

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective.descendants.collect{|t| t.to_s} +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::FamilyBefore1961.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression.to_s]
  end

  def self.assignment_method
    # aus.iczn_forgotten_name = bus
    :iczn_forgotten_name
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_iczn_forgotten_name_of(aus)
    :set_as_iczn_forgotten_name_of
  end

end

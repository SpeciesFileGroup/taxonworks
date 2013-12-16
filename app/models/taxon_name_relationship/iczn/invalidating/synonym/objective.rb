class TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective < TaxonNameRelationship::Iczn::Invalidating::Synonym

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::FamilyBefore1961.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression.to_s]
  end

  def self.assignment_method
    # aus.iczn_objective_synonym = bus
    :iczn_objective_synonym
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_iczn_objective_synonym_of(aus)
    :set_as_iczn_objective_synonym_of
  end

end

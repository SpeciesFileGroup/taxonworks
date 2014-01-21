class TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation < TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships + self.collect_to_s(
        TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective,
        TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::SynonymicHomonym,
        TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnnecessaryReplacementName)
  end

  def self.subject_relationship_name
    'unjustified emendation'
  end

  def self.object_relationship_name
    'correct original spelling'
  end

  def self.assignment_method
    # aus.iczn_unjustified_emendation = bus
    :iczn_unjustified_emendation
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_iczn_unjustified_emendation_of(aus)
    :set_as_iczn_unjustified_emendation
  end

end

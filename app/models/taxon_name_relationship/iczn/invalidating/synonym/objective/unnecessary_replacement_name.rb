class TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnnecessaryReplacementName < TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::SynonymicHomonym.to_s]
  end

  def self.assignment_method
    # aus.iczn_unnecessary_replacement_name = bus
    :iczn_unnecessary_replacement_name
  end

  # as.
  def self.inverse_assignment_method
    # bus.set_as_iczn_unnecessary_replacement_name_of(aus)
    :set_as_iczn_unnecessary_replacement_name
  end

end

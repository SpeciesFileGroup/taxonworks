class TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::SynonymicHomonym < TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnnecessaryReplacementName.to_s]
  end

end

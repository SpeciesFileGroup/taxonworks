class TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective < TaxonNameRelationship::Iczn::Invalidating::Synonym

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective.descendants.collect{|t| t.to_s} +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::FamilyBefore1961.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression.to_s]
  end

end

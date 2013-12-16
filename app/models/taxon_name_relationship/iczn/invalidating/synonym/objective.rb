class TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective < TaxonNameRelationship::Iczn::Invalidating::Synonym

  self.parent.disjoint_taxon_name_relationships +
      [TaxonNameRelationship::Iczn::Invalidating::Synonym.to_s] +
      [TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective.to_s] +
      [TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName.to_s] +
      [TaxonNameRelationship::Iczn::Invalidating::Synonym::FamilyBefore1961.to_s] +
      [TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression.to_s]

end

class TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Conditional < TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Partial.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression::Total.to_s]
  end

end
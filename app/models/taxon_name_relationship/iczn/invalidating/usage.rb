class TaxonNameRelationship::Iczn::Invalidating::Usage < TaxonNameRelationship::Iczn::Invalidating

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Iczn::Invalidating::Synonym.descendants.collect{|t| t.to_s} +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym.to_s] +
        TaxonNameRelationship::Iczn::Invalidating::Homonym.descendants.collect{|t| t.to_s} +
        [TaxonNameRelationship::Iczn::Invalidating::Homonym.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating.to_s]
  end

  def self.assignable
    false
  end

end
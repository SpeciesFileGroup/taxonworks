class TaxonNameRelationship::Iczn::Invalidating::Homonym < TaxonNameRelationship::Iczn::Invalidating

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Iczn::Invalidating::Synonym.descendants.collect{|t| t.to_s} +
        [TaxonNameRelationship::Iczn::Invalidating::Synonym.to_s] +
        TaxonNameRelationship::Iczn::Invalidating::Usage.descendants.collect{|t| t.to_s}
        [TaxonNameRelationship::Iczn::Invalidating.to_s]
  end

  def self.assignable
    true
  end

end

class TaxonNameRelationship::Iczn::Invalidating::Synonym < TaxonNameRelationship::Iczn::Invalidating

  def self.assignable
    true
  end

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Iczn::Invalidating::Usage.descendants.collect{|t| t.to_s} +
        TaxonNameRelationship::Iczn::Invalidating::Homonym.descendants.collect{|t| t.to_s} +
        [TaxonNameRelationship::Iczn::Invalidating::Homonym.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating.to_s]
  end


end
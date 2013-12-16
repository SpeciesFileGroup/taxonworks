class TaxonNameRelationship::Iczn::Validating < TaxonNameRelationship::Iczn

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Iczn::Invalidating.descendants.collect{|t| t.to_s} +
        [TaxonNameRelationship::Iczn::Invalidating.to_s]
  end

end

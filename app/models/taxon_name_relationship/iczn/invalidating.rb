class TaxonNameRelationship::Iczn::Invalidating < TaxonNameRelationship::Iczn

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Iczn::Validating.descendants.collect{|t| t.to_s} +
        [TaxonNameRelationship::Iczn::Validating.to_s]
  end

end

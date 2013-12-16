class TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary < TaxonNameRelationship::Iczn::Invalidating::Homonym

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary.descendants.collect{|t| t.to_s} +
        [TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary.to_s] +
        [TaxonNameRelationship::Iczn::Invalidating::Homonym.to_s]
  end

end

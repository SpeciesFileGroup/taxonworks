class TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary::Secondary1961 <  TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary.to_s]
  end

end

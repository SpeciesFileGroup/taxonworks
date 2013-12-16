class TaxonNameRelationship::Icn::Accepting < TaxonNameRelationship::Icn

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Icn::Unaccepting.descendants.collect{|t| t.to_s}
  end

end
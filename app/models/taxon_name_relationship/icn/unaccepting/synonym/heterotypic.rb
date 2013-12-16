class TaxonNameRelationship::Icn::Unaccepting::Synonym::Heterotypic < TaxonNameRelationship::Icn::Unaccepting::Synonym

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Icn::Unaccepting::Synonym.to_s] +
        TaxonNameRelationship::Icn::Unaccepting::Synonym::Homotypic.descendants.collect{|t| t.to_s}
  end

end
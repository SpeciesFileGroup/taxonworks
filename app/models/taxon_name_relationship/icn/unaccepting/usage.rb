class TaxonNameRelationship::Icn::Unaccepting::Usage < TaxonNameRelationship::Icn::Unaccepting

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Icn::Unaccepting.to_s] +
        TaxonNameRelationship::Icn::Unaccepting::Synonym.descendants.collect{|t| t.to_s} +
        [TaxonNameRelationship::Icn::Unaccepting::Homonym.to_s] +
        [TaxonNameRelationship::Icn::Unaccepting::Synonym.to_s] +
        [TaxonNameRelationship::Icn::Unaccepting::Rejected.to_s]
  end

end
class TaxonNameRelationship::Icn::Unaccepting::Synonym < TaxonNameRelationship::Icn::Unaccepting

  def self.assignable
    true
  end

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Icn::Unaccepting::Usage.descendants.collect{|t| t.to_s}
  end


end
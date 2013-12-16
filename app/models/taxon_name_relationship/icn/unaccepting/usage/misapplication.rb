class TaxonNameRelationship::Icn::Unaccepting::Usage::Misapplication < TaxonNameRelationship::Icn::Unaccepting::Usage

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Icn::Unaccepting::Usage::Basionym.to_s] +
        [TaxonNameRelationship::Icn::Unaccepting::Usage::Misspelling.to_s]
  end

  def self.assignable
    true
  end

end
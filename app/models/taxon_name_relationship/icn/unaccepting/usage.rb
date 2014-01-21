class TaxonNameRelationship::Icn::Unaccepting::Usage < TaxonNameRelationship::Icn::Unaccepting

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships + self.collect_to_s(
        TaxonNameRelationship::Icn::Unaccepting,
        TaxonNameRelationship::Icn::Unaccepting::Homonym,
        TaxonNameRelationship::Icn::Unaccepting::Rejected) + self.collect_descendants_and_itself_to_s(
        TaxonNameRelationship::Icn::Unaccepting::Synonym)
  end

end
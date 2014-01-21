class TaxonNameRelationship::Iczn::Invalidating::Usage < TaxonNameRelationship::Iczn::Invalidating

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships + self.collect_descendants_and_itself_to_s(
        TaxonNameRelationship::Iczn::Invalidating::Synonym,
        TaxonNameRelationship::Iczn::Invalidating::Homonym) + self.collect_to_s(
        TaxonNameRelationship::Iczn::Invalidating)
  end

  def self.assignable
    false
  end

end
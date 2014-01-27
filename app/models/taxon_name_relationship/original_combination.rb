class TaxonNameRelationship::OriginalCombination < TaxonNameRelationship

  validates_uniqueness_of :object_taxon_name_id, scope: :type

  def self.disjoint_taxon_name_relationships
    self.collect_descendants_to_s(TaxonNameRelationship::Combination)
  end

  def self.nomenclatural_priority
    :reverse
  end

end

class TaxonNameRelationship::OriginalCombination < TaxonNameRelationship

  validates_uniqueness_of :object_taxon_name_id, scope: :type

  def self.disjoint_taxon_name_relationships
    TaxonNameRelationship::Combination.descendants.collect{|t| t.to_s}
  end

  def self.priority
    :reverse
  end

end

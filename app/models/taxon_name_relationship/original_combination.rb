class TaxonNameRelationship::OriginalCombination < TaxonNameRelationship

  validates_uniqueness_of :object_taxon_name_id, scope: :type

  def self.nomenclatural_priority
    :reverse
  end

  def self.order_index
    RANKS.index(::ICN_LOOKUP[self.object_relationship_name.gsub('original ', '')])
  end

end

class TaxonNameRelationship::OriginalCombination < TaxonNameRelationship

  validates_uniqueness_of :object_taxon_name_id, scope: :type

  def self.assignable
    false
  end

end

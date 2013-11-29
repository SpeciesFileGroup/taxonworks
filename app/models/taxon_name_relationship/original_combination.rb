class TaxonNameRelationship::OriginalCombination < TaxonNameRelationship

  validates_uniqueness_of :type, scope: :object_taxon_name_id

  def self.assignable
    false
  end

end

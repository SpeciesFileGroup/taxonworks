class TaxonNameRelationship::Typification < TaxonNameRelationship

  validates_uniqueness_of :object_taxon_name_id

  def self.assignable
    false
  end

  def self.disjoint_taxon_name_relationships
    TaxonNameRelationship::Combination.descendants.collect{|t| t.to_s}
  end

end

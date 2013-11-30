class TaxonNameRelationship::OriginalCombination < TaxonNameRelationship

  #validates :name, uniqueness: { scope: :year, message: "should happen once per year" }
  validates_uniqueness_of :object_taxon_name_id, scope: :type

  def self.assignable
    false
  end

end

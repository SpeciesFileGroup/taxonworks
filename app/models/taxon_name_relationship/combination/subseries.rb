class TaxonNameRelationship::Combination::Subseries < TaxonNameRelationship::Combination

  #left_side
  def self.valid_subject_ranks
    GENUS_RANK_NAMES_ICN
  end

  # right_side
  def self.valid_object_ranks
    GENUS_AND_SPECIES_RANK_NAMES_ICN
  end

  def self.assignable
    true
  end

end

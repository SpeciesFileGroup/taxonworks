class TaxonNameRelationship::Combination::Series < TaxonNameRelationship::Combination

  #left_side
  def self.valid_subject_ranks
    GENUS_RANKS_NAMES_ICN
  end

  # right_side
  def self.valid_object_ranks
    GENUS_AND_SPECIES_RANKS_NAMES_ICN
  end

  def self.assignable
    true
  end

end

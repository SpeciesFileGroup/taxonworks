class TaxonNameRelationship::Combination::Subgenus < TaxonNameRelationship::Combination

  #left_side
  def self.valid_subject_ranks
    GENUS_RANK_NAMES
  end

  # right_side
  def self.valid_object_ranks
    GENUS_AND_SPECIES_RANK_NAMES
  end

  def self.assignment_method
    :subgenus_in_combination
  end

  # as.
  def self.inverse_assignment_method
    :combination_subgenus
  end

  def self.assignable
    true
  end

end

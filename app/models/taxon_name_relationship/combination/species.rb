class TaxonNameRelationship::Combination::Species < TaxonNameRelationship::Combination

  # left_side
  def self.valid_subject_ranks
    SPECIES_RANK_NAMES
  end

  # right_side
  def self.valid_object_ranks
    SPECIES_RANK_NAMES
  end

  def self.assignment_method
    :species_in_combination
  end

  # as.
  def self.inverse_assignment_method
    :combination_species
  end

  def self.assignable
    true
  end

end

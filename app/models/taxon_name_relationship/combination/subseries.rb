class TaxonNameRelationship::Combination::Subseries < TaxonNameRelationship::Combination

  #left_side
  def self.valid_subject_ranks
    GENUS_RANK_NAMES_ICN
  end

  # right_side
  def self.valid_object_ranks
    GENUS_AND_SPECIES_RANK_NAMES_ICN
  end

  def self.assignment_method
    :subseries_in_combination
  end

  # as.
  def self.inverse_assignment_method
    :combination_subseries
  end

  def self.assignable
    true
  end

end

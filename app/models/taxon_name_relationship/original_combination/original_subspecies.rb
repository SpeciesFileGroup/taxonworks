class TaxonNameRelationship::OriginalCombination::OriginalSubspecies < TaxonNameRelationship::OriginalCombination

  def self.valid_subject_ranks
    SPECIES_RANKS_NAMES
  end

  # right_side
  def self.valid_object_ranks
    SPECIES_RANKS_NAMES
  end

  def self.assignment_method
    # aus.original_combination_form = bus
    :original_combination_subspecies
  end

  def self.inverse_assignment_method
    # bus.set_as_species_in_original_combination(aus)
    :subspecies_in_original_combination
  end

  def self.assignable
    true
  end

end
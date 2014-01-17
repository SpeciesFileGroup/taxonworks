class TaxonNameRelationship::OriginalCombination::OriginalGenus < TaxonNameRelationship::OriginalCombination

  #left_side
  def self.valid_subject_ranks
    GENUS_RANKS_NAMES
  end

  # right_side
  def self.valid_object_ranks
    GENUS_AND_SPECIES_RANKS_NAMES
  end

  def self.assignment_method
    # aus.original_combination_genus = bus
    :original_combination_genus
  end

  # as. 
  def self.inverse_assignment_method
    # bus.set_as_genus_in_original_combination(aus)
    :genus_in_original_combination
  end

  def self.assignable
    true
  end

end

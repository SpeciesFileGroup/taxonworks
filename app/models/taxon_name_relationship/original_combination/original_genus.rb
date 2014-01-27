class TaxonNameRelationship::OriginalCombination::OriginalGenus < TaxonNameRelationship::OriginalCombination

  #left_side
  def self.valid_subject_ranks
    GENUS_RANK_NAMES
  end

  # right_side
  def self.valid_object_ranks
    GENUS_AND_SPECIES_RANK_NAMES
  end

  def self.assignment_method
    # bus.set_as_genus_in_original_combination(aus)
    :genus_in_original_combination
  end

  def self.inverse_assignment_method
    # aus.original_genus = Bus
    :original_genus
  end

  def self.assignable
    true
  end

end

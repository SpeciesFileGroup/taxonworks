class TaxonNameRelationship::OriginalCombination::OriginalSubsection < TaxonNameRelationship::OriginalCombination

  # left_side
  def self.valid_subject_ranks
    GENUS_RANK_NAMES_ICN
  end

  # right_side
  def self.valid_object_ranks
    GENUS_AND_SPECIES_RANK_NAMES_ICN
  end


  def self.assignment_method
    # aus.original_combination_form = bus
    :original_combination_subsection
  end

  # as. 
  def self.inverse_assignment_method
    # bus.set_as_form_in_original_combination(aus)
    :subsection_in_original_combination
  end

  def self.assignable
    true
  end

end

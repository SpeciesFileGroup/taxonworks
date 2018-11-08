class TaxonNameRelationship::OriginalCombination::OriginalSubgenus < TaxonNameRelationship::OriginalCombination

  #left_side
  def self.valid_subject_ranks
    GENUS_RANK_NAMES
  end

  # right_side
  def self.valid_object_ranks
    GENUS_AND_SPECIES_RANK_NAMES
  end

  def self.required_taxon_name_relationships
    self.collect_to_s(TaxonNameRelationship::OriginalCombination::OriginalGenus)
  end

  def self.assignment_method
    # bus.set_as_species_in_original_combination(aus)
    :subgenus_in_original_combination
  end

  def self.inverse_assignment_method
    # aus.original_combination_form = bus
    :original_subgenus
  end

  def self.assignable
    true
  end

end

class TaxonNameRelationship::OriginalCombination::OriginalSubspecies < TaxonNameRelationship::OriginalCombination

  def self.valid_subject_ranks
    SPECIES_RANK_NAMES
  end

  # right_side
  def self.valid_object_ranks
    SPECIES_RANK_NAMES
  end

  def self.required_taxon_name_relationships
    self.collect_to_s(TaxonNameRelationship::OriginalCombination::OriginalSpecies,
                      TaxonNameRelationship::OriginalCombination::OriginalGenus)
  end

  def self.assignment_method
    # bus.set_as_species_in_original_combination(aus)
    :subspecies_in_original_combination
  end

  def self.inverse_assignment_method
    # aus.original_form = bus
    :original_subspecies
  end

  def self.assignable
    true
  end

end
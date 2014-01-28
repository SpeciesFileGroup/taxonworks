class TaxonNameRelationship::OriginalCombination::OriginalSubseries < TaxonNameRelationship::OriginalCombination

  # left_side
  def self.valid_subject_ranks
    GENUS_RANK_NAMES_ICN
  end

  # right_side
  def self.valid_object_ranks
    GENUS_AND_SPECIES_RANK_NAMES_ICN
  end

  def self.required_taxon_name_relationships
    self.collect_to_s(TaxonNameRelationship::OriginalCombination::OriginalSeries,
                      TaxonNameRelationship::OriginalCombination::OriginalGenus)
  end

  def self.assignment_method
    # bus.set_as_form_in_original_combination(aus)
    :subseries_in_original_combination
  end

  # as. 
  def self.inverse_assignment_method
    # aus.original_combination_form = bus
    :original_subseries
  end

  def self.assignable
    true
  end

end

class TaxonNameRelationship::OriginalCombination::OriginalSpecies < TaxonNameRelationship::OriginalCombination

  def self.valid_subject_ranks
    # TODO: Dmitry fix me! 
    # Ranks.ordered_ranks_for(NomenclaturalRank::ICN::SpeciesGroup)
    [ ]
  end

  def self.valid_object_ranks
    #  Ranks.ordered_ranks_for(NomenclaturalRank::ICN::InfraspecificGroup)
  end

  def self.assignment_method
    # aus.original_combination_form = bus
    :original_combination_species
  end

  def self.inverse_assignment_method
    # bus.set_as_species_in_original_combination(aus)
    :species_in_original_combination
  end

end

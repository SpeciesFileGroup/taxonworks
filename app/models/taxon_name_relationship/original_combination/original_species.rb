class TaxonNameRelationship::OriginalCombination::OriginalSpecies < TaxonNameRelationship::OriginalCombination

  # left_side
  def self.valid_subject_ranks
    NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s} + NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup.descendants.collect{|t| t.to_s}
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s} + NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup.descendants.collect{|t| t.to_s}
  end

  def self.assignment_method
    # aus.original_combination_form = bus
    :original_combination_species
  end

  def self.inverse_assignment_method
    # bus.set_as_species_in_original_combination(aus)
    :species_in_original_combination
  end

  def self.assignable
    true
  end

end

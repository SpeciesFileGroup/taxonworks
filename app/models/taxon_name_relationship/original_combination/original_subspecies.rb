class TaxonNameRelationship::OriginalCombination::OriginalSubspecies < TaxonNameRelationship::OriginalCombination

  def self.valid_subject_ranks
    NomenclaturalRank::Iczn::SpeciesGroup.descendants + [NomenclaturalRank::Icn::Species] + NomenclaturalRank::Icn::InfraspecificGroup.descendants
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::Iczn::SpeciesGroup.descendants + [NomenclaturalRank::Icn::Species] + NomenclaturalRank::Icn::InfraspecificGroup.descendants
  end

  def self.assignment_method
    # aus.original_combination_form = bus
    :original_combination_subspecies
  end

  def self.inverse_assignment_method
    # bus.set_as_species_in_original_combination(aus)
    :subspecies_in_original_combination
  end

  def assignable
    true
  end

end
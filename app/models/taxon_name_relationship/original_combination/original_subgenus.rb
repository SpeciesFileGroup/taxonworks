class TaxonNameRelationship::OriginalCombination::OriginalSubgenus < TaxonNameRelationship::OriginalCombination

  def self.valid_subject_ranks
    NomenclaturalRank::Iczn::GenusGroup.descendants + NomenclaturalRank::Icn::GenusGroup.descendants
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::Iczn::GenusGroup.descendants + NomenclaturalRank::Iczn::SpeciesGroup.descendants + NomenclaturalRank::Icn::GenusGroup.descendants + NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup.descendants
  end

  def self.assignment_method
    # aus.original_combination_form = bus
    :original_combination_subgenus
  end

  def self.inverse_assignment_method
    # bus.set_as_species_in_original_combination(aus)
    :subgenus_in_original_combination
  end

  def self.assignable
    true
  end

end

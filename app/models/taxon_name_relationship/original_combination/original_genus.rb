class TaxonNameRelationship::OriginalCombination::OriginalGenus < TaxonNameRelationship::OriginalCombination

  def self.valid_subject_ranks
    NomenclaturalRank::ICZN::GenusGroup.descendants + NomenclaturalRank::ICN::GenusGroup.descendants
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::ICZN::GenusGroup.descendants + NomenclaturalRank::ICZN::SpeciesGroup.descendants + NomenclaturalRank::ICN::GenusGroup.descendants + NomenclaturalRank::ICN::Species + NomenclaturalRank::ICN::InfraspecificGroup.descendants
  end

  def self.assignment_method
    # aus.original_combination_form = bus
    :original_combination_genus
  end

  # as. 
  def self.inverse_assignment_method
    # bus.set_as_form_in_original_combination(aus)
    :genus_in_original_combination
  end


end

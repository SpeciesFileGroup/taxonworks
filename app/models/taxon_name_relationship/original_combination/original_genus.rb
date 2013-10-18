class TaxonNameRelationship::OriginalCombination::OriginalGenus < TaxonNameRelationship::OriginalCombination

  #left_side
  def self.valid_subject_ranks
    NomenclaturalRank::Iczn::GenusGroup.descendants + NomenclaturalRank::Icn::GenusGroup.descendants
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::Iczn::GenusGroup.descendants + NomenclaturalRank::Iczn::SpeciesGroup.descendants + NomenclaturalRank::Icn::GenusGroup.descendants + NomenclaturalRank::Icn::Species + NomenclaturalRank::Icn::InfraspecificGroup.descendants
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

class TaxonNameRelationship::OriginalCombination::OriginalSubvariety < TaxonNameRelationship::OriginalCombination

  # left_side
  def self.valid_subject_ranks
    [NomenclaturalRank::Icn::Species] + NomenclaturalRank::Icn::InfraspecificGroup.descendants
  end

  # right_side
  def self.valid_object_ranks
    [NomenclaturalRank::Icn::Species] + NomenclaturalRank::Icn::InfraspecificGroup.descendants
  end


  def self.assignment_method
    # aus.original_combination_form = bus
    :original_combination_subvariety
  end

  # as. 
  def self.inverse_assignment_method
    # bus.set_as_form_in_original_combination(aus)
    :subvariety_in_original_combination
  end


end

class TaxonNameRelationship::OriginalCombination::OriginalForm < TaxonNameRelationship::OriginalCombination

  # left_side
  def self.valid_subject_ranks
    NomenclaturalRank::ICN::Species + NomenclaturalRank::ICN::InfraspecificGroup.descendants
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::ICN::Species + NomenclaturalRank::ICN::InfraspecificGroup.descendants
  end


  def self.assignment_method
    # aus.original_combination_form = bus
    :original_combination_form
  end

  # as. 
  def self.inverse_assignment_method
    # bus.set_as_form_in_original_combination(aus)
    :form_in_original_combination
  end

end


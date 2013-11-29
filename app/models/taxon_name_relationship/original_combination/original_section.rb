class TaxonNameRelationship::OriginalCombination::OriginalSection < TaxonNameRelationship::OriginalCombination

  # left_side
  def self.valid_subject_ranks
    NomenclaturalRank::Icn::GenusGroup.descendants.collect{|t| t.to_s}
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::Icn::GenusGroup.descendants.collect{|t| t.to_s} + NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup.descendants.collect{|t| t.to_s}
  end

  def self.assignment_method
    # aus.original_combination_form = bus
    :original_combination_section
  end

  # as. 
  def self.inverse_assignment_method
    # bus.set_as_form_in_original_combination(aus)
    :section_in_original_combination
  end

  def self.assignable
    true
  end

end

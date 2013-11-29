class TaxonNameRelationship::OriginalCombination::OriginalGenus < TaxonNameRelationship::OriginalCombination

  #left_side
  def self.valid_subject_ranks
    NomenclaturalRank::Iczn::GenusGroup.descendants.collect{|t| t.to_s} + NomenclaturalRank::Icn::GenusGroup.descendants.collect{|t| t.to_s}
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::Iczn::GenusGroup.descendants.collect{|t| t.to_s} + NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s} + NomenclaturalRank::Icn::GenusGroup.descendants.collect{|t| t.to_s} + NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup.descendants.collect{|t| t.to_s}
  end

  def self.assignment_method
    # aus.original_combination_genus = bus
    :original_combination_genus
  end

  # as. 
  def self.inverse_assignment_method
    # bus.set_as_genus_in_original_combination(aus)
    :genus_in_original_combination
  end

  def self.assignable
    true
  end

end

class TaxonNameRelationship::Combination::Genus < TaxonNameRelationship::Combination

  #left_side
  def self.valid_subject_ranks
    NomenclaturalRank::Iczn::GenusGroup.descendants.collect{|t| t.to_s} + NomenclaturalRank::Icn::GenusGroup.descendants.collect{|t| t.to_s}
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::Iczn::GenusGroup.descendants.collect{|t| t.to_s} + NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s} + NomenclaturalRank::Icn::GenusGroup.descendants.collect{|t| t.to_s} + NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup.descendants.collect{|t| t.to_s}
  end

  def self.assignment_method
    :combination_genus
  end

  # as.
  def self.inverse_assignment_method
    :genus_in_combination
  end

  def self.assignable
    true
  end

end

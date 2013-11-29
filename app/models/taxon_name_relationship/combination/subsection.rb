class TaxonNameRelationship::Combination::Subsection < TaxonNameRelationship::Combination

  #left_side
  def self.valid_subject_ranks
    NomenclaturalRank::Icn::GenusGroup.descendants.collect{|t| t.to_s}
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::Icn::GenusGroup.descendants.collect{|t| t.to_s} + NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup.descendants.collect{|t| t.to_s}
  end

  def self.assignable
    true
  end

end

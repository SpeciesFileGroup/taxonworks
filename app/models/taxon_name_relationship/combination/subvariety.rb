class TaxonNameRelationship::Combination::Subvariety < TaxonNameRelationship::Combination

  # left_side
  def self.valid_subject_ranks
    [NomenclaturalRank::Icn::Species] + NomenclaturalRank::Icn::InfraspecificGroup.descendants
  end

  # right_side
  def self.valid_object_ranks
    [NomenclaturalRank::Icn::Species] + NomenclaturalRank::Icn::InfraspecificGroup.descendants
  end

end

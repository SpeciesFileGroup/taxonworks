class TaxonNameRelationship::OriginalCombination::OriginalClassifiedAs < TaxonNameRelationship::OriginalCombination

  # left_side
  def self.valid_subject_ranks
    NomenclaturalRank::Iczn.descendants + NomenclaturalRank::Icn.descendants
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::Iczn::AboveFamilyGroup.descendants + NomenclaturalRank::Iczn::FamilyGroup.descendants + NomenclaturalRank::Icn::AboveFamilyGroup.descendants + NomenclaturalRank::Icn::FamilyGroup.descendants
  end

  def self.assignable
    true
  end

end

class NomenclaturalRank::Iczn::AboveFamilyGroup::Subkingdom < NomenclaturalRank::Iczn::AboveFamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::AboveFamilyGroup::Kingdom
  end

  def self.valid_parents
    NomenclaturalRank::Iczn::AboveFamilyGroup::Kingdom
  end

  COMMON = false

end

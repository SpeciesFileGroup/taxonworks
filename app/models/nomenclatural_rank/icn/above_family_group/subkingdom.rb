class NomenclaturalRank::Icn::AboveFamilyGroup::Subkingdom < NomenclaturalRank::Icn::AboveFamilyGroup

  def self.parent_rank
    NomenclaturalRank::Icn::AboveFamilyGroup::Kingdom
  end

  def self.valid_parents
    NomenclaturalRank::Icn::AboveFamilyGroup::Kingdom
  end
end

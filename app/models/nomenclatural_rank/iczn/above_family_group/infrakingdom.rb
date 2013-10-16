class NomenclaturalRank::Iczn::AboveFamilyGroup::Infrakingdom < NomenclaturalRank::Iczn::AboveFamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::AboveFamilyGroup::Subkingdom
  end

  def self.available_parents
    NomenclaturalRank::Iczn::AboveFamilyGroup::Subkingdom
  end
end

class NomenclaturalRank::Iczn::AboveFamilyGroup::Infraorder < NomenclaturalRank::Iczn::AboveFamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::AboveFamilyGroup::Suborder
  end

  def self.valid_parents
    NomenclaturalRank::Iczn::AboveFamilyGroup::Suborder
  end

  COMMON = false

end

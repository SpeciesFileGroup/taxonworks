class NomenclaturalRank::Iczn::AboveFamilyGroup::Infrakingdom < NomenclaturalRank::Iczn::AboveFamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::AboveFamilyGroup::Subkingdom
  end

  def self.valid_parents
    NomenclaturalRank::Iczn::AboveFamilyGroup::Subkingdom
  end

  def self.common
    false
  end

end

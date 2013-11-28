class NomenclaturalRank::Iczn::AboveFamilyGroup::Infraorder < NomenclaturalRank::Iczn::AboveFamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::AboveFamilyGroup::Suborder
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::AboveFamilyGroup::Suborder.to_s]
  end

  def self.typical_use
    false
  end

end

class NomenclaturalRank::Iczn::AboveFamilyGroup::Mirorder < NomenclaturalRank::Iczn::AboveFamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::AboveFamilyGroup::Superorder
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::AboveFamilyGroup::Superorder.to_s]
  end

  def self.typical_use
    false
  end

end

class NomenclaturalRank::Iczn::AboveFamilyGroup::Suborder < NomenclaturalRank::Iczn::AboveFamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::AboveFamilyGroup::Order
  end

  def self.valid_parents
    NomenclaturalRank::Iczn::AboveFamilyGroup::Order
  end
end

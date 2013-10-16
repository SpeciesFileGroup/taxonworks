class NomenclaturalRank::Iczn::AboveFamilyGroup::Suborder < NomenclaturalRank::Iczn::AboveFamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::AboveFamilyGroup::Order
  end

  def self.available_parents
    NomenclaturalRank::Iczn::AboveFamilyGroup::Order
  end
end

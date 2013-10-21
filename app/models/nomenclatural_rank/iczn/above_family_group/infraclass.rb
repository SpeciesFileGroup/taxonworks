class NomenclaturalRank::Iczn::AboveFamilyGroup::Infraclass < NomenclaturalRank::Iczn::AboveFamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::AboveFamilyGroup::Subclass
  end

  def self.valid_parents
    NomenclaturalRank::Iczn::AboveFamilyGroup::Subclass
  end
end

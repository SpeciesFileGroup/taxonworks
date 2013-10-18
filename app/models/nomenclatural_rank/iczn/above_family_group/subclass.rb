class NomenclaturalRank::Iczn::AboveFamilyGroup::Subclass < NomenclaturalRank::Iczn::AboveFamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::AboveFamilyGroup::ClassRank
  end

  def self.valid_parents
    NomenclaturalRank::Iczn::AboveFamilyGroup::ClassRank
  end

end

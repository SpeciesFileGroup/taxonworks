class NomenclaturalRank::Iczn::AboveFamilyGroup::Infraphylum  < NomenclaturalRank::Iczn::AboveFamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::AboveFamilyGroup::Subphylum
  end

  def self.available_parents
    NomenclaturalRank::Iczn::AboveFamilyGroup::Subphylum
  end
end

class NomenclaturalRank::Iczn::FamilyGroup::Supertribe < NomenclaturalRank::Iczn::FamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::FamilyGroup::Infrafamily
  end

  def self.available_parents
    NomenclaturalRank::Iczn::FamilyGroup::Subfamily
  end
end

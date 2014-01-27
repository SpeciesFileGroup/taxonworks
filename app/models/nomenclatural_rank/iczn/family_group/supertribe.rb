class NomenclaturalRank::Iczn::FamilyGroup::Supertribe < NomenclaturalRank::Iczn::FamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::FamilyGroup::Infrafamily
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::FamilyGroup::Subfamily.to_s]
  end

  def self.typical_use
    false
  end

end

class NomenclaturalRank::Iczn::AboveFamilyGroup::Infraphylum  < NomenclaturalRank::Iczn::AboveFamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::AboveFamilyGroup::Subphylum
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::AboveFamilyGroup::Subphylum.to_s]
  end

  def self.typical_use
    false
  end

end

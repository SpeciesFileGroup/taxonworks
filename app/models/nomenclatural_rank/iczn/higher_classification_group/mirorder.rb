class NomenclaturalRank::Iczn::HigherClassificationGroup::Mirorder < NomenclaturalRank::Iczn::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::HigherClassificationGroup::Superorder
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::HigherClassificationGroup::Superorder.to_s]
  end

  def self.typical_use
    false
  end

end

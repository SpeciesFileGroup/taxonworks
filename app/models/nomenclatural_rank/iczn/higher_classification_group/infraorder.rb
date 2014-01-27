class NomenclaturalRank::Iczn::HigherClassificationGroup::Infraorder < NomenclaturalRank::Iczn::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::HigherClassificationGroup::Suborder
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::HigherClassificationGroup::Suborder.to_s]
  end

  def self.typical_use
    false
  end

end

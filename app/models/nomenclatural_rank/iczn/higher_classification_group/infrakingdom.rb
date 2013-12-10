class NomenclaturalRank::Iczn::HigherClassificationGroup::Infrakingdom < NomenclaturalRank::Iczn::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::HigherClassificationGroup::Subkingdom
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::HigherClassificationGroup::Subkingdom.to_s]
  end

  def self.typical_use
    false
  end

end

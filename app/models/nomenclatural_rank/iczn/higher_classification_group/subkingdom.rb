class NomenclaturalRank::Iczn::HigherClassificationGroup::Subkingdom < NomenclaturalRank::Iczn::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::HigherClassificationGroup::Kingdom
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::HigherClassificationGroup::Kingdom.to_s]
  end

  def self.typical_use
    false
  end

end

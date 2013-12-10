class NomenclaturalRank::Icn::HigherClassificationGroup::Subkingdom < NomenclaturalRank::Icn::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Icn::HigherClassificationGroup::Kingdom
  end

  def self.valid_parents
    [NomenclaturalRank::Icn::HigherClassificationGroup::Kingdom.to_s]
  end
end

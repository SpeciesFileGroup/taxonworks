class NomenclaturalRank::Iczn::HigherClassificationGroup::Subclass < NomenclaturalRank::Iczn::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::HigherClassificationGroup::ClassRank
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::HigherClassificationGroup::ClassRank.to_s]
  end

end

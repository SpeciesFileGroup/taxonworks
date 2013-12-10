class NomenclaturalRank::Iczn::HigherClassificationGroup::Infraphylum  < NomenclaturalRank::Iczn::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::HigherClassificationGroup::Subphylum
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::HigherClassificationGroup::Subphylum.to_s]
  end

  def self.typical_use
    false
  end

end

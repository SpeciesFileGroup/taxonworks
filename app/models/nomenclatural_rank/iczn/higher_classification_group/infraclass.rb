class NomenclaturalRank::Iczn::HigherClassificationGroup::Infraclass < NomenclaturalRank::Iczn::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::HigherClassificationGroup::Subclass
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::HigherClassificationGroup::Subclass.to_s]
  end

  def self.typical_use
    false
  end


end

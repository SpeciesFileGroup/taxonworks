class NomenclaturalRank::Iczn::HigherClassificationGroup::Suborder < NomenclaturalRank::Iczn::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::HigherClassificationGroup::Order
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::HigherClassificationGroup::Order.to_s]
  end
end

class NomenclaturalRank::Iczn::GenusGroup::Infragenus < NomenclaturalRank::Iczn::GenusGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::GenusGroup::Subgenus
  end

  def self.available_parent
    NomenclaturalRank::Iczn::GenusGroup::Subgenus
  end

  def self.common
    false
  end

end

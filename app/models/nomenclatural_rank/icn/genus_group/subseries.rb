class NomenclaturalRank::Icn::GenusGroup::Subseries < NomenclaturalRank::Icn::GenusGroup

  def self.parent_rank
    NomenclaturalRank::Icn::GenusGroup::Series
  end

  def self.available_parents
    NomenclaturalRank::Icn::GenusGroup::Series
  end

  def self.abbreviation
    "subser."
  end
end

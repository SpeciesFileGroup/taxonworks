class NomenclaturalRank::Icn::GenusGroup::Subseries < NomenclaturalRank::Icn::GenusGroup

  def self.parent_rank
    NomenclaturalRank::Icn::GenusGroup::Series
  end

  def self.valid_parents
    [NomenclaturalRank::Icn::GenusGroup::Series.to_s]
  end

  def self.abbreviation
    "subser."
  end
end

class NomenclaturalRank::Icn::GenusGroup::Subgenus < NomenclaturalRank::Icn::GenusGroup

  def self.parent_rank
    NomenclaturalRank::Icn::GenusGroup::Genus
  end

  def self.valid_parents
    [NomenclaturalRank::Icn::GenusGroup::Genus.to_s]
  end

  def self.abbreviation
    "sgen."
  end
end
